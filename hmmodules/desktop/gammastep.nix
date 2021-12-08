{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.desktop.gammastep;
in
{
  options.modules.desktop.gammastep.enable = mkEnableOption "gammastep";

  config = mkIf cfg.enable {
    services.gammastep = {
        enable = true;
        latitude = "51.0";
        longitude = "13.7";
    };
  };
}
