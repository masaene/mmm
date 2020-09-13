scriptencoding utf-8
if exists('g:loaded_mmm')
	finish
endif

let g:loaded_mmm = 1

if !exists('g:mmm_search_path')
	let g:mmm_search_path = ".,~/git/vim"
endif

if !exists('g:mmm_search_extensions')
	let g:mmm_search_extensions = "c,vim"
endif

let g:mmm_inc_map = "<SPACE><SPACE>"
execute "nnoremap <silent> ".g:mmm_inc_map." :call mmm#plugin_entry()<CR>"

command! -nargs=+ -complete=customlist,mmm#diff#complete_branch PluginGitDiff call mmm#diff#show_diff(<f-args>)

set statusline=%l/%LL\ %F\ %=Git[%{mmm#statusline#find_git_branch()}]
