# System-wide CLI/admin tooling that used to be explicit pacman packages.
{ ... }:
{
  flake.modules.nixos.base-cli =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        # filesystems / disks
        btrfs-progs
        e2fsprogs
        xfsprogs
        f2fs-tools
        jfsutils
        nilfs-utils
        dosfstools
        exfatprogs
        ntfs3g
        mtools
        lvm2
        mdadm
        cryptsetup
        gparted
        testdisk
        ddrescue
        fsarchiver
        smartmontools
        hdparm
        sg3_utils
        lsscsi
        parted
        # boot / firmware / hardware
        efibootmgr
        efitools
        sbctl
        tpm2-tools
        dmidecode
        hwinfo
        usbutils
        pciutils
        lshw
        cpupower-gui
        powertop
        # network
        dnsmasq
        bind
        nfs-utils
        traceroute
        ethtool
        inetutils
        tftp-hpa
        wget
        curl
        # basics
        vim
        nano
        less
        tree
        file
        which
        rsync
        unzip
        zip
        killall
        psmisc
        lm_sensors
      ];
      documentation = {
        enable = true;
        man.enable = true;
        dev.enable = true;
      };
      services.locate = {
        enable = true;
        package = pkgs.plocate;
      };
      services.logrotate.enable = true;
    };
}
