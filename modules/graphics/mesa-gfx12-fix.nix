# LOCAL Mesa workaround (do NOT upstream): force 4KB swizzle for mip-chained
# color render targets on GFX12. Fixes deterministic CB tile corruption
# (x_tile ^ y_tile == 13 mod 16, 1/16 of tiles dropped) on the ASUS Prime RX
# 9070 XT in mighty whenever a surface uses ADDR3_256B_2D + >=8 mips + DCC.
# Full analysis: ~/gfx12-debug/STATUS.md; patch provenance: ~/gfx12-debug/.
{ ... }:
{
  flake.modules.nixos.mesa-gfx12-fix =
    { ... }:
    {
      nixpkgs.overlays = [
        (final: prev: {
          mesa = prev.mesa.overrideAttrs (old: {
            patches = (old.patches or [ ]) ++ [ ./gfx12-4kb-swizzle.patch ];
          });
        })
      ];
    };
}
