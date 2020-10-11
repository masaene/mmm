scriptencoding utf-8

let g:mmm_pre_buf_no = 0

"overview: main loop while user is inputting any character
"arguments: none
"detail: show result what searched for every hit any key
"return: none
function! mmm#miniview#during_input(prompt, feedback_func, decide_func)
	let l:keyloop = 1
	let l:input_char = ''
	let l:input_string = ''

	redraw | echomsg a:prompt

	while l:keyloop
		let l:input_char = getchar()
		if 0x0d == l:input_char "push enter key
			let l:keyloop = 0
			"call a:decide_func(l:input_string)
			call a:decide_func(getline(getcurpos()[1]))
		elseif 0x1b == l:input_char "push ESC key
			let l:keyloop = 0
		elseif "\<BS>" == l:input_char "delete last character
			let l:input_string = substitute(l:input_string, ".$", "", "")
			call a:feedback_func(l:input_string)
			call mmm#miniview#update_selected_line_color()
			redraw | echomsg a:prompt . l:input_string
		else "push any visible character key
			if char2nr("\<C-P>") == l:input_char
				call mmm#miniview#move_upward()
			elseif char2nr("\<C-N>") == l:input_char
				call mmm#miniview#move_downward()
			elseif char2nr("\<Tab>") == l:input_char
				call mmm#miniview#move_downward()
			else
				"update input_string
				let l:input_string .= nr2char(l:input_char)
				call a:feedback_func(l:input_string)
				call mmm#miniview#update_selected_line_color()
			endif
			redraw | echomsg a:prompt . l:input_string
		endif
	endwhile
endfunction

"overview: show error message and change string color to Error
"arguments: msg : error message
"return: none
function mmm#miniview#err_msg(msg)
	if bufexists(g:mmm_buf_name)
		call setbufline(bufnr(g:mmm_buf_name),1,a:msg)
		execute 'match Error /.*/'
	endif
endfunction

"overview: change string color of hitted string
"arguments: input_string : target string
"result: none
function! mmm#miniview#update_hit_keyword_color(input_string)
	execute 'match mmmHitLine /'. escape(a:input_string,'/') . '\c/'
endfunction

"overview: adjust mmm buffer height
"arguments: match_num : matched number
"result: none
function mmm#miniview#adjust_height(match_num)
	if a:match_num == 0
		execute 'resize 1'
	elseif a:match_num < g:mmm_miniview_max_height
		execute 'resize ' . a:match_num
	else
		execute 'resize ' . g:mmm_miniview_max_height
	endif
endfunction

function mmm#miniview#move_upward()
	execute "normal k"
	execute "normal zz"
	redraw
	call mmm#miniview#update_selected_line_color()
endfunction

function mmm#miniview#move_downward()
	execute "normal j"
	execute "normal zz"
	redraw
	call mmm#miniview#update_selected_line_color()
endfunction

function mmm#miniview#open_miniview(initial_view_func)
	let g:mmm_pre_buf_no = bufnr("%")
	"new buffer for show found file
	execute 'keepalt botright ' . 'new '.g:mmm_buf_name
	setl cursorline
	call mmm#miniview#adjust_height(0)
	call a:initial_view_func()
	call mmm#miniview#update_selected_line_color()
endfunction

function mmm#miniview#close_miniview()
	execute 'bdelete!' g:mmm_buf_name
	echomsg ""
	redraw
endfunction

let s:mmm_sign_id = 1
let s:mmm_sign_mark = '**'
function mmm#miniview#update_selected_line_color()
	let l:crt_line = getcurpos()[1]
	execute '2match mmmSelectLine /.*\%' . l:crt_line . 'l/'
	return
endfunction



