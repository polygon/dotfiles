{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.systems.isolate;
in
{
  options.modules.systems.isolate.enable = mkEnableOption "Firewall isolation mode";

  config = mkIf cfg.enable {
    networking.firewall = {
      enable = true;
      allowPing = lib.mkForce false;
      allowedTCPPorts = lib.mkForce [ ];
      allowedUDPPorts = lib.mkForce [ ];
    };
  };
}
