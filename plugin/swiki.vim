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

function! PageList()
    let files = split(glob(g:swiki_root . '/' . "*"), '\n')
    if has('unix')
        let pathless = map(files, 'substitute(v:val, ".*\/", "", "")')
    else
        let pathless = map(files, 'substitute(v:val, ".*\\", "", "")')
    end
    let current_page = substitute(expand("%"),".mkd",'','')
    let extensionless = map(pathless, 'substitute(v:val, ".mkd", "", "")')
    let pagelist_without_current = filter(extensionless, 'v:val != current_page')
    return pagelist_without_current
endfunction

function! WikiLinkSelect()
    let current_ctrlp_win_location = g:ctrlp_match_window_bottom
    let g:ctrlp_match_window_bottom = 1
    let pages = PageList()
    call CtrlPGeneric(pages, 'LinkSelected')
    let g:ctrlp_match_window_bottom = current_ctrlp_win_location
endfunction

function! LinkSelected(link)
    execute "normal a[[" . a:link . "]]"
    call StartAppend()
endfunction

function! StartAppend()
    if strlen(getline(".")) > col(".")
        normal l
        startinsert
    else
        startinsert!
    endif
endfunction

function! JournalFooter()
    let time = tolower(strftime("%I:%M%p"))
    let date = strftime("%A - %b %d %G - ")
    if date == '' " Windows parses strftime different
        let date = strftime("%A - %b %d %Y - ")
    endif
    let stamp = date . time
    let padding = repeat('=', (78 - len(stamp))/2 - 3)
    let padded = padding . '\  ' . stamp . '  /' . padding
    return padded
endfunction

function! CreateJournalEntry()
    call EditWikiPage('journal')
    setl foldlevel=0
    echohl String | let title = input("Journal Entry Title: ") | echohl None
    let footer = JournalFooter()
    let template = ["# " . title, '', '', '', footer, '']
    call append(0, template)
    call cursor(3, 1)
    normal za
endfunction

function! MakeOrFollowLink()
    if InWikiLink() | call FollowLink() | else | call Linkify() | endif
endfunction

function! ExtractLinkText(wiki_link)
    let left_trimmed = substitute(a:wiki_link, '^.*\[\[', '', '')
    let full_trimmed = substitute(left_trimmed, '\]\].*$', '', '')
    " let link_text = tolower(full_trimmed)
    return full_trimmed
endfunction

function! FollowLink()
    if !InWikiLink() | return | endif
    let wiki_link = expand("<cWORD>")
    let link_text = ExtractLinkText(wiki_link)
    write
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
    let page_path = tolower(g:swiki_root . '/' . a:page . '.mkd')
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
    if empty(g:swiki_pagestack) | return | endif
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

function! OpenWikiIndex()
    call EditWikiPage('index')
endfunction

nmap <leader>wk :call OpenWikiIndex()<cr>
nmap <leader>jr :call CreateJournalEntry()<cr>

let g:swiki_pagestack = []
let g:swiki_current_page = ''
