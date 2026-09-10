# git identity + gh (GitHub CLI) as credential helper, plus git-graph and meld.
{ ... }:
{
  flake.modules.homeManager.git =
    { pkgs, ... }:
    {
      programs.git = {
        enable = true;
        settings = {
          user = {
            name = "Ampersand-ish";
            email = "ampersandish@moonwhite.com";
          };
        };
      };

      programs.gh = {
        enable = true;
        gitCredentialHelper = {
          enable = true;
          hosts = [
            "https://github.com"
            "https://gist.github.com"
          ];
        };
        settings = {
          git_protocol = "https";
          prompt = "enabled";
          prefer_editor_prompt = "disabled";
          aliases = {
            co = "pr checkout";
          };
          color_labels = "disabled";
          accessible_colors = "disabled";
          accessible_prompter = "disabled";
          spinner = "enabled";
        };
      };

      home.packages = with pkgs; [
        git-graph
        meld
      ];
    };
}
