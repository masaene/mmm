scriptencoding utf-8

let s:file_list = []
let s:was_searched = 0

"overview: filter specific files matched input keyword
"arguments: filelist : list of exist files
"arguments: keyword : string needed to filter
"return: list of filtered files
"note: use if_pyth
function! mmm#fuzzy#filter_with_keyword(filelist, keyword)
	let s:matched_list = []

	if g:mmm_use_pyth == 1 "with pyth
py3 << EOF
import re
import vim
filelist = vim.eval('a:filelist')
keyword = vim.eval('a:keyword')
for v in filelist:
	if re.search(keyword, v, re.IGNORECASE):
		vim.command('call insert(s:matched_list, "' + v + '")')
EOF
	else "without pyth
		for v in a:filelist
			if v =~ a:keyword
				call add(s:matched_list, v)
			endif
		endfor
	endif
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
				call mmm#miniview#adjust_height(len(l:matched_list))
				let l:line_idx = 1
				for v in l:matched_list
					call setbufline(bufnr(g:mmm_buf_name), l:line_idx, l:v)
					let l:line_idx = l:line_idx + 1
				endfor
				call mmm#miniview#update_hit_keyword_color(a:input_string)
			else "no hit keyword
				call mmm#miniview#adjust_height(0)
				call mmm#miniview#err_msg('No matched entry')
			endif
		else "no files
			call mmm#miniview#adjust_height(0)
			call mmm#miniview#err_msg('No matched entry')
		endif
	else
		call mmm#miniview#adjust_height(0)
	endif
endfunction

function! mmm#fuzzy#decide_input_string(decide_string)
	"return filepath on current cursor line from searched buffer
	"let l:target_filepath = getline(getcurpos()[1])
	let l:target_filepath = expand(a:decide_string)
	"back to preview window before start search
	"check exist
	if filereadable(l:target_filepath)
		execute "normal \<c-w>p"
		execute 'edit ' . l:target_filepath
	else
		call mmm#miniview#err_msg("No such file")
	endif
endfunction

"overview: create files list from specific directory
"arguments: none
"return: set result to global variable
"note: use if_pyth
function! mmm#fuzzy#get_files()
	let s:file_list = []
	let l:dir_list = split(g:mmm_search_path, ',')
	let l:ext_list = split(g:mmm_search_extensions, ',')

	if g:mmm_use_pyth == 1 "with pyth
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
	else "without pyth
		for v_dir in l:dir_list
			let l:tmp_list = glob(v_dir . "/**/*", v:true, v:true)
			for v_ext in l:ext_list
				let l:regex = "v:val =~ '" . v_ext . "'"
				let l:filtered = filter(copy(l:tmp_list), "v:val =~ '" . v_ext . "$'")
				let s:file_list += l:filtered
			endfor
		endfor
	endif
endfunction

function! mmm#fuzzy#initial_view()
	let l:line_idx = 1
	for v in v:oldfiles
		let l:filename = l:v
		if filereadable(expand(l:filename))
			call setline(l:line_idx, l:filename)
			if l:line_idx >= g:mmm_miniview_max_height
				break
			endif
			let l:line_idx = l:line_idx + 1
		endif
	endfor
	call mmm#miniview#adjust_height(l:line_idx)
endfunction
