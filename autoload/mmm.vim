scriptencoding utf-8

let s:mmm_buf_name = "mmm_win"
let g:mmm_pre_buf_no = 0

function! mmm#plugin_entry()
	"TODO:later change confirm() function.

	"color candidate: Identifier, Define, Label
	"echohl Identifier | echo "fuzzy:<f>" | echohl Define | echo "diff :<d>" | echohl None
	"let l:mode = nr2char(getchar())
	let l:mode = confirm("which mode?","&fuzzy\n&diff\n&serch")
	"if l:mode == 'f'
	if l:mode == 1 "fuzzy
		call mmm#plugin_entry_fuzzy_search()
	"elseif l:mode == 'd'
	elseif l:mode == 2 "diff
		call mmm#plugin_entry_git_diff()
	elseif l:mode == 3 "search
		call mmm#plugin_entry_search_in_file()
	else
		echomsg 'Unknown mode...'
	endif
endfunction

"overview: fuzzy search main function
"arguments: none
"return: none
function! mmm#plugin_entry_fuzzy_search()
	"new buffer for show found file
	execute 'keepalt botright 10new '.s:mmm_buf_name
	setl cursorline
	call mmm#miniview#adjust_height(0)
	let s:feedback_func = function("mmm#fuzzy#feedback_input_string")
	let s:decide_func = function("mmm#fuzzy#decide_input_string")
	call mmm#miniview#during_input('mmm:>', s:feedback_func, s:decide_func)
	execute 'bdelete!' s:mmm_buf_name
	echomsg ""
	redraw
endfunction

function! mmm#plugin_entry_search_in_file()
	"new buffer for show found file
	let g:mmm_pre_buf_no = bufnr("%")
	execute 'keepalt botright 10new '.s:mmm_buf_name
	setl cursorline
	call mmm#miniview#adjust_height(0)
	let s:feedback_func = function("mmm#search#feedback_input_string")
	let s:decide_func = function("mmm#search#decide_input_string")
	call mmm#miniview#during_input('mmm:>', s:feedback_func, s:decide_func)
	execute 'bdelete!' s:mmm_buf_name
	echomsg ""
	redraw
endfunction

"overview: git diff main function
"arguments: branch_name : diff target branch
"return: none
function! mmm#plugin_entry_git_diff()
	"run GitDiff command and push tab key to start complete
	call feedkeys(":PluginGitDiff \<Tab>", 't')
endfunction


