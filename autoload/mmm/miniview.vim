scriptencoding utf-8

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
			call a:decide_func(l:input_string)
		elseif 0x1b == l:input_char "push ESC key
			let l:keyloop = 0
		elseif "\<BS>" == l:input_char "delete last character
			let l:input_string = substitute(l:input_string, ".$", "", "")
			call a:feedback_func(l:input_string)
			redraw | echomsg a:prompt . l:input_string
		else "push any visible character key
			if char2nr("\<C-P>") == l:input_char
				call mmm#miniview#move_upward()
			elseif char2nr("\<C-N>") == l:input_char
				call mmm#miniview#move_downward()
			elseif char2nr("\<Tab>") == l:input_char "push TAB key, move to next line in list
				call mmm#miniview#move_downward()
			else
				let l:input_string .= nr2char(l:input_char)
				call a:feedback_func(l:input_string)
			endif
			redraw | echomsg a:prompt . l:input_string
		endif
	endwhile
endfunction

"overview: show error message and change string color to Error
"arguments: msg : error message
"return: none
function mmm#miniview#err_msg(msg)
	call setline(1,a:msg)
	execute 'match Error /.*/'
endfunction

"overview: change string color of hitted string
"arguments: input_string : target string
"result: none
function! mmm#miniview#update_hit_keyword_color(input_string)
	execute 'match SignColumn /'. escape(a:input_string,'/') .'\c/'
endfunction

"overview: adjust mmm buffer height
"arguments: match_num : matched number
"result: none
function mmm#miniview#adjust_height(match_num)
	if a:match_num == 0
		execute 'resize 1'
	elseif a:match_num < 10
		execute 'resize '.a:match_num
	else
		execute 'resize 10'
	endif
endfunction

function mmm#miniview#move_upward()
	execute "normal k"
	execute "normal zz"
	redraw
endfunction

function mmm#miniview#move_downward()
	execute "normal j"
	execute "normal zz"
	redraw
endfunction
