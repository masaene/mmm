scriptencoding utf-8

let s:branch_list = {}
let s:current_branch = ""

"overview:return git branch name
"arguments: none
"return: git branch name
function! mmm#statusline#find_git_branch()
	let l:filename = expand("%:p")
	let l:dir = expand("%:h")
	if has_key(s:branch_list, l:filename) == 0
		let l:result = system("cd " . l:dir . " && git rev-parse --show-toplevel")
		if v:shell_error == 0 "got git branch name
			let l:branch_name = trim(system("cd " . l:dir . " && git symbolic-ref --short HEAD"))
			let s:branch_list[l:filename] = l:branch_name
			let s:current_branch = l:branch_name
		else "Not git repository
			let s:current_branch = "-"
		endif
	else "already found git branch name
		let s:current_branch = s:branch_list[l:filename]
	endif
	return s:current_branch
endfunction
