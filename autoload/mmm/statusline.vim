scriptencoding utf-8

let s:branch_list = {}

"overview:return git branch name
"arguments: none
"return: git branch name
function! mmm#statusline#find_git_branch()
	let l:current_branch = ""
	let l:filename = expand("%:p")
	let l:dir = expand("%:p:h")
	if has_key(s:branch_list, l:filename) == 0
		let l:result = system("cd " . l:dir . " && git rev-parse --show-toplevel")
		if v:shell_error == 0 "got git branch name
			let l:branch_name = trim(system("cd " . l:dir . " && git symbolic-ref --short HEAD"))
			let s:branch_list[l:filename] = l:branch_name
			let l:current_branch = l:branch_name
		else "Not git repository
			let l:current_branch = "-"
			let s:branch_list[l:filename] = "-"
		endif
	else "already found git branch name
		if s:branch_list[l:filename] != "-"
			let l:current_branch = s:branch_list[l:filename]
		else
			let l:current_branch = "-"
		endif
	endif
	return l:current_branch
endfunction
