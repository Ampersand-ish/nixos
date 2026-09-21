# Command-line utilities (bat/btop/fzf/zoxide/eza/ripgrep/fastfetch/oh-my-posh come from apps/shell.nix).
{ ... }:
{
  flake.modules.homeManager.pkgs-cli =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        glances
        resources
        duf
        tree
        rsync
        pv
        unzip
        unrar
        wget
        libqalculate
      ];
    };
}
