if exists("b:current_syntax")
  finish
endif

runtime! syntax/markdown.vim
unlet! b:current_syntax

syntax match wikiLink "\[\[.\{-}\]\]"
highlight link wikiLink Keyword

let b:current_syntax = "swiki"
