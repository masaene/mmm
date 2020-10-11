scriptencoding utf-8

let g:mmm_miniview_max_height = 10

function! mmm#plugin_entry()
	"TODO:later change confirm() function.

	"color candidate: Identifier, Define, Label
	"echohl Identifier | echo "fuzzy:<f>" | echohl Define | echo "diff :<d>" | echohl None
	"let l:mode = nr2char(getchar())
	let l:mode = confirm("which mode?","&fuzzy\n&diff\n&serch",4)
	"if l:mode == 'f'
	if l:mode == 1 "fuzzy
		call mmm#plugin_entry_fuzzy_search()
	"elseif l:mode == 'd'
	elseif l:mode == 2 "diff
		call mmm#plugin_entry_git_diff()
	elseif l:mode == 3 "search
		call mmm#plugin_entry_search_in_file()
	else
		"do nothing
	endif
endfunction

"overview: fuzzy search main function
"arguments: none
"return: none
function! mmm#plugin_entry_fuzzy_search()
	call mmm#miniview#open_miniview(function("mmm#fuzzy#initial_view"))
	let s:feedback_func = function("mmm#fuzzy#feedback_input_string")
	let s:decide_func = function("mmm#fuzzy#decide_input_string")
	call mmm#miniview#during_input('mmm:>', s:feedback_func, s:decide_func)
	call mmm#miniview#close_miniview()
endfunction

function! mmm#plugin_entry_search_in_file()
	call mmm#miniview#open_miniview(function("mmm#search#initial_view"))
	let s:feedback_func = function("mmm#search#feedback_input_string")
	let s:decide_func = function("mmm#search#decide_input_string")
	call mmm#miniview#during_input('mmm:>', s:feedback_func, s:decide_func)
	call mmm#miniview#close_miniview()
endfunction

"overview: git diff main function
"arguments: branch_name : diff target branch
"return: none
function! mmm#plugin_entry_git_diff()
	"run GitDiff command and push tab key to start complete
	"call feedkeys(":PluginGitDiff \<Tab>", 't')

	call mmm#miniview#open_miniview(function("mmm#diff#initial_view"))
	let s:feedback_func = function("mmm#diff#feedback_input_string")
	let s:decide_func = function("mmm#diff#decide_input_string")
	call mmm#miniview#during_input('mmm:>', s:feedback_func, s:decide_func)
	call mmm#miniview#close_miniview()
endfunction


