{
  pkgs,
  lib,
  minpac,
}:
let
  opt = plugin: {
    inherit plugin;
    optional = true;
  };

  start = plugin: { inherit plugin; };
in
{
  extraPlugins = with pkgs.vimPlugins; [
    (start catppuccin-nvim)
    (start vim-dispatch)
    (start vim-obsession)
    (start vim-projectionist)
    (start vim-fugitive)
    (start bufexplorer)
    (start plenary-nvim)
    (start promise-async)
    (start nvim-ufo)
    (start nvim-coverage)
    (start fzf-vim)
    (opt vim-polyglot)
    (opt minpac)
    (opt gruvbox)
    (opt vim-startuptime)
    (opt nerdtree)
    (opt seoul256-vim)
    (opt vim-grepper)
  ];

  files."keymap/workman-p.vim".extraConfigVim = builtins.readFile ./workman-p.vim;

  extraConfigVim = ''
    let g:polyglot_disabled = ['autoindent']

    ${builtins.readFile ./vimrc}

    set completeopt=menuone,noinsert,fuzzy

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
  '';

  extraConfigLua = builtins.readFile ./init.lua;

  extraConfigLuaPost = lib.mkOrder 1500 ''

    local addon = vim.env.HOME .. "/.lintd/nvim/addon.lua"
    if vim.fn.filereadable(addon) == 1 then
      dofile(addon)
    end
  '';
}
