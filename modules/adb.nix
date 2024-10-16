{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.apps.adb;
in
{
  options.modules.apps.adb.enable = mkEnableOption "Android Debug Bridge";

  config = mkIf cfg.enable {
    programs.adb.enable = true;
    users.users.jan.extraGroups = ["adbusers"];
  };
}
