scriptencoding utf-8

"overview: 
"arguments: none
"return: none
function! mmm#cmd#inc() range
	"TODO experimental impl
	let l:num = a:firstline
	while l:num <= a:lastline
		echo getline(l:num)
		let l:num = l:num + 1
	endwhile
endfunction
