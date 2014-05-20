" folding for Markdown headers, both styles (atx- and setex-)
" http://daringfireball.net/projects/markdown/syntax#header
"
" this code can be placed in file
"   $HOME/.vim/after/ftplugin/markdown.vim
"
" original version from Steve Losh's gist: https://gist.github.com/1038710

function! MarkdownFold(lnum)
  "let head = s:head(a:lnum)
  let head = s:head_code(a:lnum)
  if head
    return head
  "elseif a:lnum != line('$')
  "  let next = s:head(a:lnum + 1)
  "  if next
  "    return '<' . next
  "  endif
  endif
  if s:is_code
    return '='
  else
    return '0'
  endif
endfunction

let s:is_code = 0
function! s:head_code(lnum)
  let current = getline(a:lnum)
  let sharps = strlen(matchstr(current, '^```'))
  if sharps
    if s:is_code
      let s:is_code=0
    else
      let s:is_code=1
    endif
    return 1
  endif
  return 0
endfunction


function! s:head(lnum)
  let current = getline(a:lnum)
  let sharps = strlen(matchstr(current, '^#*'))
  if sharps
    return sharps
  endif

  " <h2> <h3> ...
  let h = matchstr(current, '^\s*<\s*h\zs\d\ze\>') - 0
  if h
    return h
  endif

  if current =~ '\S'
    let next = getline(a:lnum + 1)
    if next =~ '^=\+$'
      return 1
    elseif next =~ '^-\+$'
      return 2
    endif
  endif
  return 0
endfunction

func! Foldexpr_markdown(lnum)
    if (a:lnum == 1)
        let l0 = ''
    else
        let l0 = getline(a:lnum-1)
    endif

    let l1 = getline(a:lnum)

    let l2 = getline(a:lnum+1)

    if  l2 =~ '^==\+\s*'
        " next line is underlined (level 1)
        return '>1'
    elseif l2 =~ '^--\+\s*'
        " next line is underlined (level 2)
        return '>2'
    elseif l1 =~ '^#'
        " don't include the section title in the fold
        return '-1'
    elseif l0 =~ '^#'
        " current line starts with hashes
        return '>'.matchend(l0, '^#\+')
    else
        " keep previous foldlevel
        return '='
    endif
endfunc


if !exists("g:vim_markdown_folding_disabled")
  setlocal foldexpr=MarkdownFold(v:lnum)
  setlocal foldmethod=expr

  " allow the initial foldlevel to be configured in .vimrc
  if !exists("g:vim_markdown_initial_foldlevel")
    let g:vim_markdown_initial_foldlevel=0
  endif
  let &l:foldlevel=g:vim_markdown_initial_foldlevel

  "---------- everything after this is optional -----------------------
  " change the following fold options to your liking
  " see ':help fold-options' for more
  setlocal foldenable
  setlocal foldcolumn=0
  set foldmethod=expr
  set foldopen-=search
endif
