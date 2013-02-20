if exists("b:did_ftplugin")
    finish
endif

runtime! ftplugin/markdown.vim
runtime after/ftplugin/markdown/folding.vim

nmap <buffer> <cr> :call MakeOrFollowLink()<cr>
vmap <buffer> <cr> :call VisualLinkify()<cr>
nmap <buffer> <bs> :call PopPageStack()<cr>
nmap <buffer> <leader>wl /\[\[.\{-}\]\]<cr>
imap <buffer> <C-l> :silent call WikiLinkSelect()<cr>
nmap <buffer> <tab> :call FindNextLink()<cr>
nmap <buffer> <S-tab> :call FindPreviousLink()<cr>
setlocal foldlevel=1
