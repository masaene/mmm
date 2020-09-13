scriptencoding utf-8

let s:mmm_buf_name = "mmm_win"

function! mmm#plugin_entry()
	"TODO:later change confirm() function.

	"color candidate: Identifier, Define, Label
	echohl Identifier | echo "fuzzy:<f>" | echohl Define | echo "diff :<d>" | echohl None
	let l:mode = nr2char(getchar())
	if l:mode == 'f'
		call mmm#plugin_entry_fuzzy_search()
	elseif l:mode == 'd'
		call mmm#plugin_entry_git_diff()
	elseif l:mode == 0x09
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
	"run GitDiff command and push tab key to start complete
	call feedkeys(":GitDiff \<Tab>", 't')
endfunction
