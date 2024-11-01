{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # trials on one host
    charasay

    (runCommand "com.lemonade"
      {
        buildInputs = [
          lemonade
        ];
      }
      ''
        mkdir -p $out/bin/
        cat << EOF > $out/bin/com.lemonade
        #!/usr/bin/env bash
          ${pkgs.lemonade}/bin/lemonade server &
          lemon=\$!
          trap "kill \$lemon" EXIT
          ssh -vNR 2489:127.0.0.1:2489 com
        EOF
        chmod +x $out/bin/com.lemonade
      ''
    )
  ];

  programs.helix.enable = true; # NOTICE learning
  programs.emacs.enable = true; # TODO pack configs

  fool.misc.gtr = true;

  fool.cargo.ctrl-config = true;
  fool.gpg.pinentry = pkgs.pinentry-qt;
  fool.proxy.use-pi = true;
  fool.git.github-proxy = true;
  fool.zsh = {
    enable = true;
    with-skim = true;
  };
  fool.cfg-ssh = {
    vultr = true;
    qcraft = true;
  };
  fool.nvim.lsp = true;
  fool.alacritty = {
    enable = true;
    font-size = 10;
  };
  fool.attic.watch-store = true;
}
