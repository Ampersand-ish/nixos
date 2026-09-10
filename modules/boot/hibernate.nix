# Hibernation to the btrfs swapfile on the LUKS root (offset filled in post-install via hostSpec.resumeOffset).
{ ... }:
{
  flake.modules.nixos.hibernate =
    { config, lib, ... }:
    {
      boot.resumeDevice = "/dev/mapper/cryptroot";
      boot.kernelParams = lib.optional (
        config.hostSpec.resumeOffset != null
      ) "resume_offset=${toString config.hostSpec.resumeOffset}";

      systemd.sleep.settings.Sleep = {
        AllowSuspendThenHibernate = "yes";
        HibernateDelaySec = "120min";
        SuspendState = "mem";
        HibernateMode = "platform shutdown";
      };

      services.logind.settings.Login = {
        HandleLidSwitch = "suspend-then-hibernate";
        HandleLidSwitchExternalPower = "suspend";
        HandleLidSwitchDocked = "ignore";
        HandlePowerKey = "suspend-then-hibernate";
      };
    };
}
