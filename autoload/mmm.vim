scriptencoding utf-8

let g:mmm_buf_name = "mmm_win"
let g:mmm_miniview_max_height = 10

function! mmm#plugin_entry()

	""""""""""
	" manuallly showing menu
	""""""""""
	"what is number which indicate orange?
	execute "highlight mmmFuzzy ctermfg=208" 
	execute "highlight mmmDiff ctermfg=LightBlue"
	execute "highlight mmmSearch ctermfg=LightYellow"
	execute "highlight mmmSymbol ctermfg=DarkGreen"
	echohl mmmFuzzy | echo "fuzzy:<f>"
	echohl mmmDiff | echo "diff:<d>"
	echohl mmmSearch | echo "search:<s>"
	echohl mmmSymbol | echo "symbol:<b>"
	echohl None

	let l:mode_char = nr2char(getchar())
	if l:mode_char == 'f'
		let l:mode_num = 1
	elseif l:mode_char == 'd'
		let l:mode_num = 2
	elseif l:mode_char == 's'
		let l:mode_num = 3
	elseif l:mode_char == 'b'
		let l:mode_num = 4
	else
		let l:mode_num = 0
	endif

	""""""""""
	" use confirm()
	""""""""""
	"let l:mode_num = confirm("which mode?","&fuzzy\n&diff\n&serch",4)


	if l:mode_num == 1 "fuzzy
		call mmm#plugin_entry_fuzzy_search()
	elseif l:mode_num == 2 "diff
		call mmm#plugin_entry_git_diff()
	elseif l:mode_num == 3 "search
		call mmm#plugin_entry_search_in_file()
	elseif l:mode_num == 4 "symbol
		call mmm#plugin_entry_symbol_in_file()
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

function! mmm#plugin_entry_symbol_in_file()

	execute "highlight mmmSymbolFunc ctermfg=LightBlue"
	execute "highlight mmmSymbolFuncStatic ctermfg=Blue"
	execute "highlight mmmSymbolValue ctermfg=LightRed"
	execute "highlight mmmSymbolValueStatic ctermfg=Red"
	execute "highlight mmmSymbolDefine ctermfg=LightGreen"
	execute "highlight mmmSymbolDefineStatic ctermfg=Green"
	execute "highlight mmmSymbolStruct ctermfg=LightMagenta"
	execute "highlight mmmSymbolStructStatic ctermfg=Magenta"
	execute "highlight mmmSymbolOther ctermfg=none"

	call mmm#miniview#open_miniview(function("mmm#symbol#initial_view"))
	let s:feedback_func = function("mmm#symbol#feedback_input_string")
	let s:decide_func = function("mmm#symbol#decide_input_string")
	call mmm#miniview#during_input('mmm:>', s:feedback_func, s:decide_func)
	call mmm#miniview#close_miniview()
endfunction
