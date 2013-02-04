autocmd BufNewFile,BufRead *.markdown,*.md,*.mdown,*.mkd,*.mkdn
      \ if s:InSwikiFolder() |
      \   set ft=swiki |
      \ endif

function! s:InSwikiFolder()
    if !exists("g:swiki_root") |
        return 0
    endif
    if expand(g:swiki_root) == expand("%:p:h")
        return 1
    else
        return 0
    endif
endfunction
