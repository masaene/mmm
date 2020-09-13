scriptencoding utf-8

let s:mmm_buf_name = "mmm_win"

"overview: 
"arguments: none
"return: none
function! mmm#diff#complete_branch(lead, line, pos)
	let l:dir = expand("%:p:h")
	let l:ret = system("cd " . l:dir . " && git branch -a")
	if v:shell_error == 0 "ok
		let l:branch_list_org = []
		for v in split(l:ret, '\n')
			call insert(l:branch_list_org, trim(l:v))
		endfor
		let l:candidate_branch_list = []
py3 << EOF
import re
import vim
branch_list_org = vim.eval('l:branch_list_org')
for v in branch_list_org:
	if re.search('remotes/', v):
		branch_name = re.sub('remotes/', '', v.split(' ')[0])
		vim.command('call insert(l:candidate_branch_list, "' + branch_name + '")')
EOF
	endif
	return l:candidate_branch_list
endfunction

function! mmm#diff#show_diff(branch_name)
	let l:filename = expand("%:p")
	let l:dir = expand("%:p:h")
	let l:git_top_org = system('cd ' . l:dir . ' && git rev-parse --show-toplevel')
	let l:git_top = escape(trim(l:git_top_org),'/')
	let l:relative_path = substitute(l:filename, l:git_top."\/", "", "")

	execute 'diffthis'
	execute 'vnew'
	execute 'lcd ' . l:dir
	execute '%!git show ' . a:branch_name . ':' . l:relative_path
	execute 'diffthis'
	setl buftype=nofile
	setl nobuflisted
	setl nomodifiable
	
endfunction
