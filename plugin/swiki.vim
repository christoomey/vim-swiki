function! InWikiLink()
    let false = 0
    let true = 1
    let cword = expand("<cWORD>")
    let wiki_link_pattern = '\[\[.*\]\]'
    let match_start_index = match(cword, wiki_link_pattern)
    if match_start_index == -1
        return false
    else
        return true
    endif
endfunction

function! MakeOrFollowLink()
    if InWikiLink() | call FollowLink() | else | call Linkify() | endif
endfunction

function! ExtractLinkText(wiki_link)
    let left_trimmed = substitute(a:wiki_link, '^\[\[', '', '')
    let full_trimmed = substitute(left_trimmed, '\]\]$', '', '')
    let link_text = tolower(full_trimmed)
    return link_text
endfunction

function! FollowLink()
    if !InWikiLink() | return | endif
    let wiki_link = expand("<cWORD>")
    let link_text = ExtractLinkText(wiki_link)
    call EditWikiPage(link_text)
endfunction

function! VisualLinkify()
    let column = col('.')
    let line = line('.')
    normal! gv
    normal "ly
    let link_text = @l
    let fixed_link_text = substitute(link_text, " ", "-", "g")
    normal! gv
    execute 'normal "lc[[' . fixed_link_text . ']]'
    call cursor(line, column+4)
endfunction

function! Linkify()
    let column = col('.')
    let line = line('.')
    normal "lciw[[l]]
    call cursor(line, column+2)
endfunction

function! EditWikiPage(page)
    let page_path = g:swiki_root . a:page . '.mkd'
    let page_is_new = !filereadable(expand(page_path))
    execute "silent edit " . page_path
    if (g:swiki_current_page=='')
        let g:swiki_current_page = a:page
    else
        call insert(g:swiki_pagestack, g:swiki_current_page)
        let g:swiki_current_page = a:page
    end
    if page_is_new
        let title_line = "# " . a:page
        call append(0, [title_line, ""])
    endif
endfunction

function! PopPageStack()
    let prior_page = remove(g:swiki_pagestack, 0)
    let g:swiki_current_page = ''
    call EditWikiPage(prior_page)
endfunction

function! FindNextLink()
    call FindLink('forward')
endfunction

function! FindPreviousLink()
    call FindLink('backward')
endfunction

function! FindLink(direction)
    let @/ = "\\[\\[.\\{-}\\]\\]"
    if InWikiLink()
        let char_after_cursor = getline('.')[col('.')]
        if char_after_cursor != "["
            normal F[F[
        endif
    endif
    if a:direction == "forward"
        normal n
    else
        normal N
    endif
    nohlsearch
    normal 2l
endfunction

function! WikiMode()
    nmap <buffer> <cr> :call MakeOrFollowLink()<cr>
    vmap <buffer> <cr> :call VisualLinkify()<cr>
    nmap <buffer> <bs> :call PopPageStack()<cr>
    nmap <buffer> <leader>wl /\[\[.\{-}\]\]<cr>
    nmap <tab> :call FindNextLink()<cr>
    nmap <S-tab> :call FindPreviousLink()<cr>
    syntax match wikiLink "\[\[.\{-}\]\]"
    highlight link wikiLink Keyword
    setlocal foldlevel=1
endfunction

function! OpenWikiIndex()
    call EditWikiPage('index')
    call WikiMode()
endfunction

let g:swiki_pagestack = []
let g:swiki_current_page = ''
let g:swiki_root = '~/swiki/'
execute "autocmd BufNewFile,BufRead " . g:swiki_root . "* call WikiMode()"
nmap <leader>wik :call OpenWikiIndex()<cr>
