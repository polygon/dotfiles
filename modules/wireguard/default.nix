{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.wireguard;
in
{
  imports = [ ./wacken.nix ./mullvad.nix ];

  options.modules.wireguard.enable = mkEnableOption "wireguard";

  config = mkIf cfg.enable {
    networking.wireguard.enable = true;
  };
}
