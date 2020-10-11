scriptencoding utf-8

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

function! mmm#diff#feedback_input_string(input_string)
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
input_string = vim.eval('a:input_string')
for v in branch_list_org:
	if re.search('remotes/', v) and re.search(input_string, v):
		branch_name = re.sub('remotes/', '', v.split(' ')[0])
		vim.command('call insert(l:candidate_branch_list, "' + branch_name + '")')
EOF
	endif
	call mmm#miniview#adjust_height(len(l:candidate_branch_list))
	let l:line_idx = 1
	for v in l:candidate_branch_list
		call setline(l:line_idx, l:v)
		let l:line_idx = l:line_idx + 1
	endfor
	call mmm#miniview#update_hit_keyword_color(a:input_string)
endfunction

function! mmm#diff#decide_input_string(decide_string)
	let l:branch_name = a:decide_string
	let l:filename = expand("#".g:mmm_pre_buf_no.":p")
	let l:extension = expand("#".g:mmm_pre_buf_no.":e")
	let l:dir = expand("#".g:mmm_pre_buf_no.":p:h")
	let l:git_top_org = system('cd ' . l:dir . ' && git rev-parse --show-toplevel')
	let l:git_top = escape(trim(l:git_top_org),'/')
	let l:relative_path = substitute(l:filename, l:git_top."\/", "", "")

	execute "normal \<c-w>p"
	execute 'diffthis'
	execute 'vnew ' . 'mmm_diff/' . a:decide_string . ':' . l:relative_path
	execute 'lcd ' . l:dir
	execute '%!git show ' . a:decide_string . ':' . l:relative_path
	execute 'diffthis'
	setl buftype=nofile
	setl nobuflisted
	setl nomodifiable
endfunction

function! mmm#diff#initial_view()
	
endfunction
