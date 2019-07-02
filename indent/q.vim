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

fun! SynIDname(lnum, col)
    return synIDattr(synID(a:lnum, a:col, 1), 'name')
endfun

fun! IsInString(lnum, col)
    return SynIDname(a:lnum, a:col) ==  "kString"
endfun

fun! IsInComment(lnum, col)
    let name = SynIDname(a:lnum, a:col)
    return (name ==  "kComment") || (name ==  "kSpecialComment")
endfun

" [-- return the sum of indents with a forward limit --]
fun! KIndentDiff(lnum)
    " starts with a comment
    if IsInComment(a:lnum, 1)
        return 0
    endif

    "echom "diff for lnum: " . a:lnum
    let diffline = getline(a:lnum)
    "echom "diff for: " . diffline

    let last = len(diffline)
    "echom "last: " . last

    " empty line
    if last < 0
        return 0
    endif

    let i = 1

    let res = 0

    " iterate over all line columns
    while i <= last
        " string indexes are 0-based, columns are 1-based
        let c = diffline[i - 1]

        "echom c . " [" . i . "] ======= " . res
        if IsInComment(a:lnum, i)
            "echom "comment"
            " if we found a comment, we can skip the rest
            break
        endif

        " skip strings
        let isstring = IsInString(a:lnum, i)
        "echom "isstring: " . isstring
        "echom "IsInString(" . a:lnum . ", " . a:col . ")"
        if ! isstring
            " here we are not in a comment or string
            " need to tally open/closed

            if 0 == match(c, '[[{(]')
                "echom "open"
                let res = res + 1
            elseif 0 == match(c, '[\]})]')
                "echom "close"
                let res = res - 1
            endif
        endif

        let i = i + 1
    endwhile

    "echom "res: " . res

    return res
endfun

fun! KIndentGet(lnum)

    " At the start of the file, use zero indent.
    if a:lnum == 0
        return 0
    endif

    " Find a non-empty line above the current line.
    let pnum = prevnonblank(a:lnum - 1)

    let pdiff = KIndentDiff(pnum)

    let diff = pdiff

    "echom "line: " . a:lnum
    "echom "pnum: " . pnum
    "echom "pdiff: " . pdiff
    "echom "diff: " . diff

    let pindent = indent(pnum)
    let res = max([0, pindent + (&sw * diff) ])

    return res
endfun

" [-- EOF <runtime>/indent/k.vim --]
