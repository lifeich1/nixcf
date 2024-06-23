{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.fool.zsh;
in
{
  options.fool.zsh = {
    enable = mkEnableOption "zsh with my configuration";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      fastfetch
      zsh-powerlevel10k
      meslo-lgs-nf
      eza
      du-dust
      bat
      cheat
    ];

    home.file.".lintd/zsh/custom/themes/powerlevel10k" = {
      source = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k";
    };

    home.file.".lintd/zsh/zshrc".source = ./zshrc;
    home.file.".lintd/zsh/zshenv".source = ./zshenv;
    home.file.".lintd/zsh/p10k.zsh".source = ./p10k.zsh;

    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      oh-my-zsh = {
        enable = true;
        theme = "powerlevel10k/powerlevel10k";
        custom = "$HOME/.lintd/zsh/custom";
        plugins = [
          "git"
          "gitignore"
          "gh"
          "ubuntu"
          "emoji"
          "emoji-clock"
          "cp"
          "rust"
          "perl"
          "poetry"
        ];
      };
      initExtraFirst = ''
        fastfetch --pipe false

        # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
        # Initialization code that may require console input (password prompts, [y/n]
        # confirmations, etc.) must go above this block; everything else may go below.
        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
      '';
      initExtra = ''
        source ~/.lintd/zsh/zshrc
        source ~/.lintd/zsh/p10k.zsh
      '';
      envExtra = ''
        source ~/.lintd/zsh/zshenv
      '';
    };

  };
}
