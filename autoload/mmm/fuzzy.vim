scriptencoding utf-8

let s:mmm_buf_name = "mmm_win"
let s:file_list = []
let s:prompt = 'mmm:> '
let s:was_searched = 0

"overview: filter specific files matched input keyword
"arguments: filelist : list of exist files
"arguments: keyword : string needed to filter
"return: list of filtered files
"note: use if_pyth
function! mmm#fuzzy#filter_with_keyword(filelist, keyword)
	let s:matched_list = []
py3 << EOF
import re
import vim
filelist = vim.eval('a:filelist')
keyword = vim.eval('a:keyword')
for v in filelist:
	if re.search(keyword, v):
		vim.command('call insert(s:matched_list, "' + v + '")')
EOF
	return s:matched_list
endfunction

"overview: show searched list that mathed user inputted keyword on current buffer
"arguments: input_string : keyword needed to search
"return: none
function! mmm#fuzzy#feedback_input_string(input_string)
	"search if it has not already searched files
	if s:was_searched == 0
		call mmm#fuzzy#get_files()
		let s:was_searched = 1
	endif

	execute '%d'
	execute 'match none'
	if len(a:input_string) != 0 "no input
		if len(s:file_list) != 0 "show only matched filename with user inputted keyword
			let l:matched_list = mmm#fuzzy#filter_with_keyword(s:file_list, a:input_string)
			if len(l:matched_list) != 0 "hit any file
				call mmm#fuzzy#adjust_height(len(l:matched_list))
				let l:line_idx = 1
				for v in l:matched_list
					call setline(l:line_idx, l:v)
					let l:line_idx = l:line_idx + 1
				endfor
				call mmm#fuzzy#update_hit_keyword_color(a:input_string)
			else "no hit keyword
				call mmm#fuzzy#adjust_height(0)
				call mmm#fuzzy#err_msg('No matched entry')
			endif
		else "no files
			call mmm#fuzzy#adjust_height(0)
			call mmm#fuzzy#err_msg('No matched entry')
		endif
	else
		call mmm#fuzzy#adjust_height(0)
	endif
endfunction

function! mmm#fuzzy#decide_input_string(input_string)
	"return filepath on current cursor line from searched buffer
	let l:target_filepath = getline(getcurpos()[1])
	"back to preview window before start search
	execute "normal \<c-w>p"
	"check exist
	if filereadable(l:target_filepath)
		execute 'edit ' . l:target_filepath
	else
		echomsg "No such file"
	endif
endfunction

"overview: move cursor to next line in searched list
"arguments: none
"return: none
function! mmm#fuzzy#move_on_list()
	execute "normal j"
	execute "normal zz"
	redraw
endfunction

"overview: main loop while user is inputting any character
"arguments: none
"return: none
function! mmm#fuzzy#during_input()
	let l:keyloop = 1
	let l:input_char = ''
	let l:input_string = ''

	redraw | echomsg s:prompt

	while l:keyloop
		let l:input_char = getchar()
		if 0x0d == l:input_char "push enter key
			let l:keyloop = 0
			call mmm#fuzzy#decide_input_string(l:input_string)
		elseif 0x09 == l:input_char "move to next line in list
			call mmm#fuzzy#move_on_list()
		elseif 0x1b == l:input_char "push ESC key
			let l:keyloop = 0
		elseif "\<BS>" == l:input_char "delete last character
			let l:input_string = substitute(l:input_string, ".$", "", "")
			call mmm#fuzzy#feedback_input_string(l:input_string)
			redraw | echomsg s:prompt . l:input_string
		else "push any visible character key
			let l:input_string .= nr2char(l:input_char)
			call mmm#fuzzy#feedback_input_string(l:input_string)
			redraw | echomsg s:prompt . l:input_string
		endif
	endwhile
endfunction

"overview: create files list from specific directory
"arguments: none
"return: set result to global variable
"note: use if_pyth
function! mmm#fuzzy#get_files()
	let s:file_list = []
	let l:dir_list = split(g:mmm_search_path, ',')
	let l:ext_list = split(g:mmm_search_extensions, ',')
py3 << EOF
import os
import re
import glob
dir_list = vim.eval('l:dir_list')
ext_list = vim.eval('l:ext_list')

#convert list to regular expression
#ex: "c,vim" => "/*\.(c|vim)"
ext_re = '/*\.(' + '|'.join(ext_list) + ')'

for directory in dir_list:
	#expand ~ to home directory
	ret = [p for p in glob.glob(os.path.expanduser(directory) + '/**/*', recursive=True) if re.search(ext_re, str(p))]
	for name in ret:
		vim.command('call insert(s:file_list, "' + name + '")')
EOF
endfunction

"overview: show error message and change string color to Error
"arguments: msg : error message
"return: none
function mmm#fuzzy#err_msg(msg)
	call setline(1,a:msg)
	execute 'match Error /.*/'
endfunction

"overview: change string color of hitted string
"arguments: input_string : target string
"result: none
function! mmm#fuzzy#update_hit_keyword_color(input_string)
	execute 'match SignColumn /'. escape(a:input_string,'/') .'\c/'
endfunction

"overview: adjust mmm buffer height
"arguments: match_num : matched number
"result: none
function mmm#fuzzy#adjust_height(match_num)
	if a:match_num == 0
		execute 'resize 1'
	elseif a:match_num < 10
		execute 'resize '.a:match_num
	else
		execute 'resize 10'
	endif
endfunction

