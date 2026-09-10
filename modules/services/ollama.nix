# ollama with CUDA (the `acceleration` option was removed upstream; pick the cuda package).
{ ... }:
{
  flake.modules.nixos.ollama =
    { pkgs, ... }:
    {
      services.ollama = {
        enable = true;
        package = pkgs.ollama-cuda;
        environmentVariables = {
          OLLAMA_FLASH_ATTENTION = "1";
          OLLAMA_NUM_PARALLEL = "1";
          CUDA_VISIBLE_DEVICES = "0";
        };
      };
    };
}
