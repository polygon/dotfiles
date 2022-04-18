{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.skeleton;
in
{
  options.modules.skeleton.enable = mkEnableOption "skeleton";

  config = mkIf cfg.enable {
      # Config here
  };
}
