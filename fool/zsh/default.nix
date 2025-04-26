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

  imports = [
    ./skim.nix
    ./instant-prompt.nix
  ];

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
      initContent = ''
        source ~/.lintd/zsh/zshrc
        source ~/.lintd/zsh/p10k.zsh
      '';
      envExtra = ''
        source ~/.lintd/zsh/zshenv
      '';
    };

    programs.zellij.enableZshIntegration = false;

  };
}
