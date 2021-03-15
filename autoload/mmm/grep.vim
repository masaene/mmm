scriptencoding utf-8

"overview: search current file, and result lists will appear in miniview.

let s:file_list = []
let s:was_searched = 0
let s:grep_ret_list = []

"overview: 
"arguments: input_string : keyword needed to search
"return: none
function! mmm#grep#feedback_input_string(input_string)
	execute '%d'
	execute 'match none'
	if len(a:input_string) != 0 "no input
		let l:matched_list = []

		let l:matched_list = filter(copy(s:grep_ret_list), {idx, val -> val =~? a:input_string})
"		for v in s:grep_ret_list
"			if v =~? a:input_string
"				call add(l:matched_list, v)
"			endif
"		endfor

		if len(l:matched_list) != 0 "there are some string
			call mmm#miniview#adjust_height(len(l:matched_list))
			let l:line_idx = 1
			for v in l:matched_list
				call setline(l:line_idx, v)
				let l:line_idx = l:line_idx + 1
			endfor
			call mmm#miniview#update_hit_keyword_color(a:input_string)
			call matchadd("mmmGrepLinenumber", ':\zs\d\+\ze:', 2)
		else "no hit keyword
			call mmm#miniview#adjust_height(0)
			call mmm#miniview#err_msg('No matched entry')
		endif
	else
		call mmm#miniview#adjust_height(0)
	endif
endfunction

function! mmm#grep#decide_input_string(decide_string)
	"return filepath on current cursor line from searched buffer
	"let l:line_info = getline(getcurpos()[1])
	if a:decide_string != ""
		let l:line_info = split(a:decide_string, ":")
		let l:filename = l:line_info[0]
		let l:linenumber = l:line_info[1]

		execute "normal \<c-w>p"
		execute "edit " . l:filename
		execute l:linenumber
		execute "normal zz"
	endif
endfunction

function! mmm#grep#initial_view()
	"execute "vimgrep /" . "_alloc" . "/j */**/*"
	"let s:grep_ret = getqflist()
	echo "grep running..."
	let l:sys_ret = system("grep -wrn --binary-files=without-match '" . g:mmm_pre_buf_word_on_cursor . "' ./*")
	let s:grep_ret_list = split(l:sys_ret, '\n')
	call mmm#grep#feedback_input_string(g:mmm_pre_buf_word_on_cursor)

endfunction
