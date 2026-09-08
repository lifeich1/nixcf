{ lib, ... }:
with lib;
{
  globals = {
    mapleader = " ";
    maplocalleader = "\\";
    polyglot_disabled = [ "autoindent" ];
    fzf_buffers_jump = 1;
  };

  opts = {
    expandtab = true;
    tabstop = 2;
    shiftwidth = 2;
    softtabstop = -1;
    backspace = [
      "eol"
      "start"
      "indent"
    ];
    ruler = true;
    compatible = false;
    showcmd = true;
    fileencodings = [
      "utf-8"
      "gbk"
      "latin1"
    ];
    modelines = 5;
    sessionoptions = [
      "buffers"
      "curdir"
      "help"
      "tabpages"
      "terminal"
      "winsize"
    ];
    foldlevel = 99;
    foldenable = true;
    foldcolumn = "1";
    foldlevelstart = 99;
    completeopt = [
      "menuone"
      "noinsert"
      "fuzzy"
    ];
    clipboard = [ "unnamedplus" ];
    keymap = "workman-p";
  };

  autoGroups = {
    py_iden.clear = true;
  };

  autoCmd = [
    {
      event = "BufEnter";
      group = "py_iden";
      pattern = "*.py";
      command = "setlocal tabstop=4 shiftwidth=4";
    }
  ];
}