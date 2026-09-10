# Neovim with LazyVim: ~/.config/nvim is a mutable out-of-store symlink into home/nvim (lazy.nvim manages
# plugins at runtime; lua/matugen.lua is written by noctalia). HM's programs.neovim is NOT used because it
# always generates an init.lua, which would collide with the symlinked directory.
{ ... }:
{
  flake.modules.homeManager.neovim =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        neovim
        # LazyVim / Mason helpers and language servers used by the config
        gcc
        gnumake
        ripgrep
        fd
        lazygit
        lua-language-server
        stylua
        tinymist
        typst
        nodejs
        tree-sitter
      ];
      desktop.outOfStore.nvim = "home/nvim";
      home.sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
      };
    };
}
