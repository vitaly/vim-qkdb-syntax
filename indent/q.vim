" Description:  k indenter
" Author:       simon garland <simon_garland@gmx.net>
" URL:          http://271828.net/vim/indent/k.vim
" Last Change:  $Date: 2001/09/11 05:33:24 $

" Only load this indent file when no other was loaded.
if exists("b:did_indent")
    finish
endif
let b:did_indent = 1

" [-- local settings (must come before aborting the script) --]
setlocal indentexpr=KIndentGet(v:lnum)
setlocal indentkeys=o,O,*<Return>,<Bs>,!^F,<{>,<}>,<[>,<]>

" [-- count indent-increasing '{[' of k line a:lnum --]
fun! <SID>KIndentOpen(line)
    return strlen(substitute(a:line, '[^{[(]\+', '', 'g'))
endfun

" [-- count indent-decreasing ']}' of k line a:lnum --]
fun! <SID>KIndentClose(line)
    return strlen(substitute(a:line, '[^}\])]\+', '', 'g'))
endfun

" [-- return true if line is a comment --]
fun! <SID>KStripComment(line)
    let res = substitute(a:line, '\s/.*$', '', '')
    let res = substitute(res, '^/.*$', '', '')
    return res
endfun

" [-- return -1 if line starts with a closing indent character (e.g. [{( --]
fun! <SID>KClosing(line)
    if 0 == match(a:line, '^\s*[}\])]')
        return -1
    end
    return 0
endfun

" [-- return the sum of indents with a forward limit --]
fun! <SID>KIndentDiff(line)
    return min([1, <SID>KIndentOpen(a:line) - <SID>KIndentClose(a:line)])
endfun

fun! KIndentGet(lnum)

    " At the start of the file, use zero indent.
    if a:lnum == 0
        return 0
    endif

    let line = getline(a:lnum)

    " Find a non-empty line above the current line.
    let pnum = prevnonblank(a:lnum - 1)

    let pline = getline(pnum)
    echom "pline: " . pline

    let pline = <SID>KStripComment(pline)

    echom "pline w/o comments: " . pline

    let pindent = indent(pnum)

    let pclosing = <SID>KClosing(pline)

    let pdiff = <SID>KIndentDiff(pline)

    let closing = <SID>KClosing(line)

    let diff = (closing - pclosing + pdiff)

    let res = max([0, pindent + (&sw * diff) ])

    return res
endfun

fun! Foo(lnum)
    return <SID>KIndentGet(a:lnum)
endfun

" [-- EOF <runtime>/indent/k.vim --]
