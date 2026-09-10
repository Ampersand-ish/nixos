# gnome-keyring (unlocked by PAM at SDDM login), gcr ssh agent, polkit, dbus-broker.
{ ... }:
{
  flake.modules.nixos.keyring-polkit = {
    security.polkit.enable = true;
    services.gnome.gnome-keyring.enable = true;
    security.pam.services.sddm.enableGnomeKeyring = true;
    security.pam.services.login.enableGnomeKeyring = true;
    services.gnome.gcr-ssh-agent.enable = true;
    programs.ssh.startAgent = false;
    services.dbus.implementation = "broker";
  };
}
