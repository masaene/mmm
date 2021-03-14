scriptencoding utf-8

"overview: search current file, and result lists will appear in miniview.

let s:file_list = []
let s:was_searched = 0

"overview: 
"arguments: input_string : keyword needed to search
"return: none
function! mmm#search#feedback_input_string(input_string)
	execute '%d'
	execute 'match none'
	if len(a:input_string) != 0 "no input
		let l:matched_list = []
		let l:line_no = 1
		for v in getbufline(g:mmm_pre_buf_no,1,"$")
			if v =~? a:input_string
				call add(l:matched_list, {"no":l:line_no,"line":v})
			endif
			let l:line_no += 1
		endfor

		if len(l:matched_list) != 0 "there are some string
			call mmm#miniview#adjust_height(len(l:matched_list))
			let l:line_idx = 1
			for v in l:matched_list
				call setline(l:line_idx, printf("%5d:%s",l:v["no"],l:v["line"]))
				let l:line_idx = l:line_idx + 1
			endfor
			call mmm#miniview#update_hit_keyword_color(a:input_string)
		else "no hit keyword
			call mmm#miniview#adjust_height(0)
			call mmm#miniview#err_msg('No matched entry')
		endif
	else
		call mmm#miniview#adjust_height(0)
	endif
endfunction

function! mmm#search#decide_input_string(decide_string)
	"return filepath on current cursor line from searched buffer
	"let l:line_info = getline(getcurpos()[1])
	if a:decide_string != ""
		let l:line_info = a:decide_string

		"a:decide_string example = '    120:  func()'
		"acquire line number
		let l:no = trim(split(l:line_info, ":")[0])
		"back to preview window before start search
		execute "normal \<c-w>p"
		"exec line number, cursor will move to indicated line number
		execute l:no
		execute "normal zz"
	endif
endfunction

function! mmm#search#initial_view()

endfunction
