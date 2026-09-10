# Development toolchains and editors (git/gh/neovim/meld/git-graph/opencode live in their own aspects).
{ ... }:
{
  flake.modules.homeManager.pkgs-dev =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        vim
        nano
        docker-compose
        gradle
        typst
        tinymist
        pandoc
        xmlstarlet
        rustup
        nodejs
        (python3.withPackages (
          ps: with ps; [
            defusedxml
            packaging
            pyqt5
            secretstorage
          ]
        ))
        jdk
        perl
        claude-code
        gemini-cli
      ];
    };
}
