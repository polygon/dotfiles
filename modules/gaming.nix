{ config, lib, pkgs, ... }:

with lib;

# Base config for all Linux systems

let
  cfg = config.modules.apps.gaming;
in
{
  options.modules.apps.gaming.enable = mkEnableOption "Gaming";

  config = mkIf cfg.enable {
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "gfn" ''
        # usage: gfn [cmsId [shortName [parentGameId]]]
        FP=${config.services.flatpak.package}/bin/flatpak
        [ -z "$1" ] && exec "$FP" run com.nvidia.geforcenow
        route="#?cmsId=$1&launchSource=External"
        [ -n "$2" ] && route="$route&shortName=$2"
        [ -n "$3" ] && route="$route&parentGameId=$3"
        exec "$FP" run --command=/app/cef/GeForceNOW com.nvidia.geforcenow "--url-route=$route"
      '')
    ];

    services.flatpak.enable = true;
    programs.steam = {
      enable = true;
      extest.enable = true;
    };
    programs.gamemode.enable = true;

  };
}
