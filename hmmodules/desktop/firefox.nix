{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.desktop.firefox;
in
{
  options.modules.desktop.firefox.enable = mkEnableOption "firefox";

  config = mkIf cfg.enable {
    programs.firefox = {
        enable = true;
        profiles.myprofile.settings = {
        "general.smoothScroll" = true;
        };
    };
  };
}
