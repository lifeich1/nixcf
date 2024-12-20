let g:polyglot_disabled = ['autoindent']

set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

"tmapclear

"set timeoutlen=50
set clipboard+=unnamedplus

tnoremap <Esc> <C-\><C-n>
tnoremap <C-v><Esc> <Esc>
if filereadable("/home/fool/opt/miniconda3/bin/python3")
  let g:python3_host_prog="/home/fool/opt/miniconda3/bin/python3"
endif
if filereadable("/home/fool/opt/perl5/perlbrew/perls/perl-5.34.1/bin/perl")
  let g:perl_host_prog="/home/fool/opt/perl5/perlbrew/perls/perl-5.34.1/bin/perl"
endif

tnoremap <M-h> <C-\><C-n><C-w><C-h>
tnoremap <M-j> <C-\><C-n><C-w><C-j>
tnoremap <M-k> <C-\><C-n><C-w><C-k>
tnoremap <M-l> <C-\><C-n><C-w><C-l>
tnoremap <M--> <C-\><C-n>gT
tnoremap <M-=> <C-\><C-n>gt
tnoremap <M-9> <C-\><C-n>:-tabmove<CR>
tnoremap <M-0> <C-\><C-n>:+tabmove<CR>

cnoremap <Bslash>at RSPCAutoTest<cr>
cnoremap <Bslash>qt !rm keeptest<cr>

luaf ~/.vim/init.lua

function! s:modu(path)
  if filereadable(a:path)
    if a:path =~ '.lua$'
      execute "luaf " . a:path
    elseif a:path =~ '.vim$'
      execute "source " . a:path
    else
      throw 'Invalid file extension: ' . a:path
    endif
  endif
endfunction

" ~/.lintd/nvim/lsp.lua
call s:modu($HOME . "/.lintd/nvim/lsp.lua")

" the leftover for test addon & clipboard platform-related optimize code
call s:modu($HOME . "/.lintd/nvim/addon.lua")
