{ pkgs, osConfig, ... }:

{
  programs.helix.enable = true; # NOTICE learning
  programs.emacs.enable = true; # TODO pack configs

  # cargo mirror (thin desktop-only config, inlined per plan 05 step 2)
  home.file.".cargo/config.toml".text = ''
    [source.crates-io]
    replace-with = 'mirror'

    [source.mirror]
    registry = "sparse+https://mirrors.tuna.tsinghua.edu.cn/crates.io-index/"
  '';
  fool.desktop.apps.enable = true;
  fool.desktop.programs.enable = true;
  fool.misc.nixbuild = true;
  fool.com-lemonade.enable = true;
  fool.reasonix.enable = true;
  fool.dsh = {
    enable = true;
    package = pkgs.dsh.dsh;
    profiles = {
      web.bundles = [ pkgs.dsh.bundles.web-app ];
      tui.bundles = [ pkgs.dsh.bundles.tui ];
    };
    defaultProfile = "tui";

    # JuFlow 是 OpenAI 兼容中转；手写 pi-ai 路由必须同时声明协议、端点
    # 和非空模型列表。密钥只引用凭据名，值不进入 Nix。
    patch = [
      {
        id = "llm-pi-ai";
        config.providers.juflow = {
          displayName = "JuFlow";
          api = "openai-completions";
          baseURL = "https://juflowai.com/v1";
          apiKeyEnv = "JUFLOW_API_KEY";
          models = [
            # { id = "DeepSeek-V4-Pro-0813"; }
            # { id = "qwen3.8-max"; }
            # { id = "glm-5.3"; }
            # { id = "glm-5.3-flash"; }
            # { id = "DeepSeek-V4.1-flash"; }
            # JuFlow 路由不在 pi-ai 内置目录中，未声明时回退到 262,144；
            # 该模型官方上下文窗口为 1M。
            {
              id = "DeepSeek-V4.1-Flash-1017";
              contextWindow = 1000000;
            }
            # { id = "kimi-k3.1-pro"; }
            # { id = "kimi-k3"; }
          ];
        };
      }
    ];
  };
  fool.kdocs.enable = true;
  fool.gpg.pinentry = pkgs.pinentry-qt;
  fool.proxy.use-pi = true;
  fool.git.github-proxy = true;
  fool.zsh = {
    enable = true;
    with-skim = true;
  };
  fool.cfg-ssh.hosts = {
    emotions = {
      hostName = "64.64.237.104";
      port = 6027;
      user = "root";
    };
    scintilla = {
      hostName = "64.176.38.71";
      user = "root";
    };
    lclpi = {
      hostName = osConfig.fool.homelab.pi.lanAddress;
      user = "pi";
    };
    opi1 = {
      hostName = "192.168.3.60";
      user = "root";
    };
    gtr = {
      hostName = "192.168.3.4";
      user = "fool";
    };
  };
  fool.nvim.lsp = true;
  fool.nvim.markdown = true;
  fool.alacritty.enable = true;
  fool.fastfetch.enable = true;
  programs.zellij.enable = true;
  # 备用交互 shell：安装 nushell，但不改变 users.nix 中 zsh 的默认登录 shell
  programs.nushell = {
    enable = true;
    loadSessionVariables = false;
  };
}
