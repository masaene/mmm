scriptencoding utf-8
if exists('g:loaded_mmm')
	finish
endif

let g:loaded_mmm = 1

if !exists('g:mmm_search_path')
	let g:mmm_search_path = "."
endif

if !exists('g:mmm_search_extensions')
	let g:mmm_search_extensions = ".*"
endif

let g:mmm_inc_map = "<SPACE><SPACE>"
execute "nnoremap <silent> ".g:mmm_inc_map." :call mmm#plugin_entry_fuzzy_search()<CR>"
