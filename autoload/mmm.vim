scriptencoding utf-8

let s:mmm_buf_name = "mmm_win"

"overview: fuzzy search main function
"arguments: none
"return: none
function! mmm#plugin_entry_fuzzy_search()
	"new buffer for show found file
	execute 'keepalt botright 10new '.s:mmm_buf_name
	setl cursorline
	call mmm#fuzzy#adjust_height(0)
	call mmm#fuzzy#during_input()
	execute 'bdelete!' s:mmm_buf_name
	echomsg ""
	redraw
endfunction

"overview: git diff main function
"arguments: branch_name : diff target branch
"return: none
function! mmm#plugin_entry_git_diff()

endfunction
