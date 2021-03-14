scriptencoding utf-8

"overview: search current file, and result lists will appear in miniview.

let s:file_list = []
let s:was_searched = 0
let s:all_definition_list = []
let s:all_definition_dict = {}
let s:last_filename = ""

"overview: 
"arguments: input_string : keyword needed to search
"return: none
function! mmm#symbol#feedback_input_string(input_string)
	execute '%d'
	execute 'match none'
	if len(a:input_string) != 0 "no input
		let l:matched_list = []
		for v in s:all_definition_list
			if v["name"] =~? a:input_string
				call add(l:matched_list, v) "dict in list cell
			endif
		endfor

		if len(l:matched_list) != 0 "hit any file
			call mmm#miniview#adjust_height(len(l:matched_list))
			let l:line_idx = 1

			for v in l:matched_list
				call setline(l:line_idx, v["name"])
				call mmm#symbol#sign_each_symboltype(l:line_idx, v["def"])
				let l:line_idx = l:line_idx + 1
			endfor
			call mmm#miniview#update_hit_keyword_color(a:input_string)
		else "no hit keyword
			call mmm#miniview#adjust_height(0)
			call mmm#miniview#err_msg('No matched entry')
		endif
	else
		call mmm#miniview#adjust_height(0)
		call mmm#miniview#err_msg('No matched entry')
	endif
endfunction

function! mmm#symbol#decide_input_string(decide_string)
	execute "normal \<c-w>p"

	let l:jump_number = s:all_definition_dict[a:decide_string]["jump"]
	if l:jump_number != 0
		execute l:jump_number
	else
		let l:search_word = s:all_definition_dict[a:decide_string]["search"]
		execute l:search_word
		execute "noh"
	endif

	execute "normal zz"
endfunction

function! mmm#symbol#initial_view()
 	"manually search function definition = ^\w\+\s\+\w\+(.*)

	let l:current_file = split(g:mmm_pre_buf_name,"/")[-1]
	echomsg l:current_file

	"at first create list
	if s:last_filename != l:current_file
		let s:last_filename = l:current_file
		let s:all_definition_list = []
		let s:all_definition_dict = {}

		"it will not nomarlly run, if following definition on other script file.
		execute "sign define sign_def_symbol_func text=F texthl=mmmSymbolFunc linehl=mmmSymbolFunc"
		execute "sign define sign_def_symbol_func_static text=f texthl=mmmSymbolFuncStatic linehl=mmmSymbolFuncStatic"
		execute "sign define sign_def_symbol_value text=V texthl=mmmSymbolValue linehl=mmmSymbolValue"
		execute "sign define sign_def_symbol_value_static text=v texthl=mmmSymbolValueStatic linehl=mmmSymbolValueStatic"
		execute "sign define sign_def_symbol_define text=D texthl=mmmSymbolDefine linehl=mmmSymbolDefine"
		execute "sign define sign_def_symbol_define_static text=d texthl=mmmSymbolDefineStatic linehl=mmmSymbolDefineStatic"
		execute "sign define sign_def_symbol_struct text=S texthl=mmmSymbolStruct linehl=mmmSymbolStruct"
		execute "sign define sign_def_symbol_struct_static text=s texthl=mmmSymbolStructStatic linehl=mmmSymbolStructStatic"
		execute "sign define sign_def_symbol_other text=- texthl=mmmSymbolOther linehl=mmmSymbolOther"

		let l:line_idx = 1

		for tagfile in split(g:mmm_tagfile_name,",")
			let l:cmd = "grep -w " . "\"" . escape(l:current_file, ".") . "\" " . tagfile
			let l:ret = system(l:cmd)
			for hit_str in split(l:ret, "\n")
				let l:name = split(hit_str, '\s')[0]
				let l:def = split(hit_str, ';"')[-1] 
				"call setline(l:line_idx, l:name . ":" . l:def)
				if hit_str =~ '.*\s\d\+;"'
					let l:search_word = ""
					let l:jump_number = substitute(hit_str, '.*\s\(\d\+\);".*', '\1', 'g')
				else
					let l:search_word = substitute(hit_str, '.*\(\/\^.*\/\);".*', '\1', 'g')
					let l:jump_number = 0
				endif
				call add(s:all_definition_list, {"line": l:line_idx, "name": l:name, "def": l:def}) "add dict as list cell(need to hold additional order)
				let s:all_definition_dict[l:name] = {"search":escape(l:search_word,"*[]"), "jump": jump_number}
				let l:line_idx = l:line_idx + 1
			endfor
		endfor
		
		if l:line_idx == 1 "is initial value
			call mmm#miniview#adjust_height(0)
			call mmm#miniview#err_msg('No matched entry')
		endif

	"already created list
	else
		let l:line_idx = len(s:all_definition_list)
	endif

	call mmm#miniview#adjust_height(l:line_idx)
	call mmm#symbol#feedback_input_string('.*')
	call mmm#miniview#clear_hit_keyword_color()

endfunction

"overview: 
"note: support only c-kinds of ctags
function! mmm#symbol#sign_each_symboltype(line_idx, def)

	let l:type_func = 0x01
	let l:type_value = 0x02
	let l:type_define = 0x03
	let l:type_struct = 0x04
	let l:scope_global = 0x10
	let l:scope_static = 0x20
	let l:hl_id = 0x00

	let l:aaaa = {or(0x01,0x10):"JJ"}

	let l:hl_name_dict =	{
												\ or(l:type_func, l:scope_global): "sign_def_symbol_func",
												\ or(l:type_func, l:scope_static): "sign_def_symbol_func_static",
												\ or(l:type_value, l:scope_global): "sign_def_symbol_value",
												\ or(l:type_value, l:scope_static): "sign_def_symbol_value_static",
												\ or(l:type_define, l:scope_global): "sign_def_symbol_define",
												\ or(l:type_define, l:scope_static): "sign_def_symbol_define_static",
												\ or(l:type_struct, l:scope_global): "sign_def_symbol_struct",
												\ or(l:type_struct, l:scope_static): "sign_def_symbol_struct_static",
												\ }
							

	"parse definition
	"e.g. separete symbol type and symbol scope.
	"f
	"f	file
	"v
	"v	file
	let l:def_list = split(a:def, '\t')
	let l:type = l:def_list[0]

	if l:type == 'f'
		let l:hl_id = l:type_func
	elseif l:type == 'v'
		let l:hl_id = l:type_value
	elseif l:type == 'd'
		let l:hl_id = l:type_define
	elseif l:type == 's'
		let l:hl_id = l:type_struct
	else
		let l:hl_id = 0x00
	endif

	if (len(l:def_list) > 1) && (l:def_list[1] == 'file:')
		let l:hl_id = or(l:hl_id, l:scope_static)
	else
		let l:hl_id = or(l:hl_id, l:scope_global)
	endif

	if has_key(l:hl_name_dict,l:hl_id)
			execute "sign place " . a:line_idx . " line=" . a:line_idx . " name=" . l:hl_name_dict[l:hl_id] . " file=" . g:mmm_buf_name 
	else
			execute "sign place " . a:line_idx . " line=" . a:line_idx . " name=sign_def_symbol_other file=" . g:mmm_buf_name 
	endif
endfunction
