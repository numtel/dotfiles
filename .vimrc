call pathogen#infect()
set nu
set colorcolumn=80
set expandtab
set tabstop=2
set shiftwidth=2
set mouse=a
set ai

" Highlight trailing spaces
match ErrorMsg '\s\+$'

syntax enable
filetype plugin on
filetype on
au BufNewFile,BufRead *.ino setlocal ft=c
au BufNewFile,BufRead *.less setlocal ft=css
au BufNewFile,BufRead * setlocal formatoptions-=cro
au BufNewFile,BufRead *.frag,*.vert,*.fp,*.vp,*.glsl setf glsl
" Commenting blocks of code.
function CommentType()
  for def in [
\        ['// ', ['c', 'cpp', 'java', 'scala', 'js', 'javascript', 'php', 
\                 'glsl']],
\        ['# ', ['sh', 'ruby', 'python', 'conf', 'fstab', 'coffee']],
\        ['" ', ['vim']]
\      ]
    if(index(def[1], &ft)>-1)
      return def[0]
    endif
  endfor
  return ''
endfunction

function Comment(fl, ll)
  let i=a:fl
  let comment=CommentType()
  while i<=a:ll
    let cl=getline(i)
    let cl2=comment.cl
    call setline(i, cl2)
    let i=i+1
  endwhile
endfunction

function UnComment(fl, ll)
  let i=a:fl
  let comment=CommentType()
  while i<=a:ll
    let cl=getline(i)
    let cl2=substitute(cl, "^\s*" . comment, "", "")
    call setline(i, cl2)
    let i=i+1
  endwhile
endfunction
noremap <silent> ,cc :call Comment(line("."), line("."))<CR>
noremap <silent> ,cu :call UnComment(line("."), line("."))<CR>

" Rename.vim  -  Rename a buffer within Vim and on the disk
"
" Copyright June 2007-2011 by Christian J. Robinson <heptite@gmail.com>
"
" Distributed under the terms of the Vim license.  See ":help license".
"
" Usage:
"
" :Rename[!] {newname}

command! -nargs=* -complete=file -bang Rename call Rename(<q-args>, '<bang>')

function! Rename(name, bang)
  let l:name    = a:name
  let l:oldfile = expand('%:p')

  if bufexists(fnamemodify(l:name, ':p'))
    if (a:bang ==# '!')
      silent exe bufnr(fnamemodify(l:name, ':p')) . 'bwipe!'
    else
      echohl ErrorMsg
      echomsg 'A buffer with that name already exists (use ! to override).'
      echohl None
      return 0
    endif
  endif

  let l:status = 1

  let v:errmsg = ''
  silent! exe 'saveas' . a:bang . ' ' . l:name

  if v:errmsg =~# '^$\|^E329'
    let l:lastbufnr = bufnr('$')

    if expand('%:p') !=# l:oldfile && filewritable(expand('%:p'))
      if fnamemodify(bufname(l:lastbufnr), ':p') ==# l:oldfile
        silent exe l:lastbufnr . 'bwipe!'
      else
        echohl ErrorMsg
        echomsg 'Could not wipe out the old buffer for some reason.'
        echohl None
        let l:status = 0
      endif

      if delete(l:oldfile) != 0
        echohl ErrorMsg
        echomsg 'Could not delete the old file: ' . l:oldfile
        echohl None
        let l:status = 0
      endif
    else
      echohl ErrorMsg
      echomsg 'Rename failed for some reason.'
      echohl None
      let l:status = 0
    endif
  else
    echoerr v:errmsg
    let l:status = 0
  endif

  return l:status
endfunction
