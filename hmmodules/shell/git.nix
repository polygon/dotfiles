{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.shell.git;
in
{
  options.modules.shell.git.enable = mkEnableOption "git";

  config = mkIf cfg.enable {
    programs.git = {
        enable = true;
        userName = "polygon";
        userEmail = "polygon@wh2.tu-dresden.de";
    };
  };
}
