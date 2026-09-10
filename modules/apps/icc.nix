# Load a display ICC profile via ArgyllCMS dispwin when the niri session starts (laptop panels only).
{ ... }:
{
  flake.modules.homeManager.icc =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.desktop.icc;
    in
    {
      options.desktop.icc = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Whether to load an ICC display profile with dispwin at session start.";
        };
        profile = lib.mkOption {
          type = lib.types.path;
          default = ../../home/hosts/moonwhite/display.icc;
          description = "ICC profile to install with `dispwin -I`.";
        };
      };

      config = lib.mkIf cfg.enable {
        home.packages = [ pkgs.argyllcms ];

        systemd.user.services.laptop-icc = {
          Unit = {
            Description = "Load laptop factory ICC colour profile for niri";
            PartOf = [ "niri.service" ];
            After = [ "niri.service" ];
          };
          Service = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStart = "${pkgs.argyllcms}/bin/dispwin -I ${cfg.profile}";
          };
          Install = {
            WantedBy = [ "niri.service" ];
          };
        };
      };
    };
}
