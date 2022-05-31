{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.shell.common;
in
{
  options.modules.shell.common.enable = mkEnableOption "common";

  config = mkIf cfg.enable {
    programs.fzf.enable = true;

    home.packages = with pkgs; [
      nix-index
      wget
      htop
      traceroute
      ripgrep
      jq
      file
      unzip
      p7zip
    ];
  };
}