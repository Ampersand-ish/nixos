# Interactive shell: zsh + oh-my-posh + fzf/zoxide/bat/eza, session env, ssh-agent and gnome-keyring.
{ ... }:
{
  flake.modules.homeManager.shell =
    { config, pkgs, ... }:
    {
      xdg.enable = true;

      programs.zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;

        plugins = [
          {
            name = "fzf-tab";
            src = pkgs.zsh-fzf-tab;
            file = "share/fzf-tab/fzf-tab.plugin.zsh";
          }
        ];

        oh-my-zsh = {
          enable = true;
          plugins = [
            "git"
            "sudo"
            "aws"
            "kubectl"
            "kubectx"
            "command-not-found"
          ];
          # oh-my-zsh runs compinit itself (completionInit is skipped when it is enabled);
          # keep the dump out of $HOME like the old .zshrc did.
          extraConfig = ''
            ZSH_COMPDUMP="''${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
          '';
        };

        history = {
          size = 5000;
          path = "${config.home.homeDirectory}/.zsh_history";
          share = true;
          ignoreDups = true;
          ignoreAllDups = true;
          ignoreSpace = true;
          append = true;
          saveNoDups = true;
          findNoDups = true;
        };

        shellAliases = {
          ls = "ls --color";
          vim = "nvim";
          c = "clear";
          cat = "bat";
          btop = "btop --force-utf";
          mpvHDR = "env ENABLE_HDR_WSI=1 gamescope --prefer-vk-device 10de:ffff --backend drm -O DP-1 -W 3840 -H 2160 -f --hdr-enabled -- mpv --vo=gpu-next --gpu-api=vulkan --target-colorspace-hint --target-prim=bt.2020 --target-trc=pq --tone-mapping=auto";
        };

        completionInit = ''
          autoload -Uz compinit
          compinit -d "''${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
        '';

        initContent = ''
          # Keybindings
          bindkey -e
          bindkey '^p' history-search-backward
          bindkey '^n' history-search-forward
          bindkey '^[w' kill-region

          # Completion styling
          zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
          zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
          zstyle ':completion:*' menu no
          zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
          zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
        '';
      };

      programs.oh-my-posh = {
        enable = true;
        enableZshIntegration = true;
        settings = builtins.fromTOML (builtins.readFile ../../home/ohmyposh/config.toml);
      };

      programs.fzf = {
        enable = true;
        enableZshIntegration = true;
      };

      programs.zoxide = {
        enable = true;
        enableZshIntegration = true;
        options = [
          "--cmd"
          "cd"
        ];
      };

      programs.bat = {
        enable = true;
        config.theme = "noctalia";
      };

      programs.direnv = {
        enable = true;
        enableZshIntegration = true;
        nix-direnv.enable = true;
      };

      programs.eza.enable = true;
      programs.ripgrep.enable = true;
      programs.fastfetch.enable = true;

      home.sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
        SUDO_EDITOR = "nvim";
        CARGO_HOME = "${config.xdg.dataHome}/cargo";
        RUSTUP_HOME = "${config.xdg.dataHome}/rustup";
        NPM_CONFIG_USERCONFIG = "${config.xdg.configHome}/npm/npmrc";
        GRADLE_USER_HOME = "${config.xdg.dataHome}/gradle";
        CUDA_CACHE_PATH = "${config.xdg.cacheHome}/nv";
      };

      home.sessionPath = [
        "$HOME/bin"
        "$HOME/.local/bin"
        "$HOME/.npm-global/bin"
      ];

      systemd.user.sessionVariables = {
        __GL_SHADER_DISK_CACHE_SIZE = "12000000000";
        MPD_HOST = "/run/user/1000/mpd/socket";
      };

      services.ssh-agent.enable = true;
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        matchBlocks."*".addKeysToAgent = "yes";
      };

      services.gnome-keyring = {
        enable = true;
        components = [
          "pkcs11"
          "secrets"
        ];
      };
    };
}
