{
  description = "ampersand's NixOS - dendritic flake (spicy-niri, CachyOS kernel, disko + lanzaboote)";

  nixConfig = {
    extra-substituters = [
      "https://niri.cachix.org"
      "https://attic.xuyh0120.win/lantian"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "niri.cachix.org-1:Xfjzn4R91yzPPQd4r7s06DH7gvz/OEApKd68GYcIQwM="
      "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    import-tree.url = "github:vic/import-tree";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.1.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri-flake = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia-shell = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # DankMaterialShell (tracks the latest release tag via the stable branch).
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # DankSearch (dsearch): fast file search backing the DMS launcher.
    danksearch = {
      url = "github:AvengeMedia/danksearch";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Proton-CachyOS (community package; auto-tracks CachyOS releases).
    nix-proton-cachyos = {
      url = "github:kimjongbing/nix-proton-cachyos";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Deliberately NOT following nixpkgs: overlays.pinned must match the
    # nixpkgs the kernels were built against to hit the lantian binary cache.
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    # CachyOS-Settings as a standalone NixOS module (sysctl, udev, systemd, ZRAM, THP, I/O).
    cachyos-settings = {
      url = "github:Daaboulex/cachyos-settings-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # spicy-niri: losnoco's niri fork + its smithay fork (sibling path dep).
    niri-spicy-src = {
      url = "github:losnoco/niri/spicy-main";
      flake = false;
    };
    smithay-spicy-src = {
      url = "github:losnoco/smithay/spicy-master";
      flake = false;
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.flake-parts.flakeModules.modules
        (inputs.import-tree ./modules)
      ];
    };
}
