{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.desktop.vscode;
in
{
  options.modules.desktop.vscode.enable = mkEnableOption "vscode";

  config = mkIf cfg.enable {
    programs.vscode = {
      enable = true;
      package = pkgs.vscodium;
      extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
        vadimcn.vscode-lldb
        matklad.rust-analyzer
        ms-vscode-remote.remote-ssh
        ms-python.python
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "command-server";
          publisher = "pokey";
          version = "0.8.2";
          sha256 = "sha256-mVDXn8jygpmshr7Xxve57JV3UMci3oeeLHr5dWirkOw=";
        }
        {
          name = "cursorless";
          publisher = "pokey";
          version = "0.26.495";
          sha256 = "sha256-VR1LMA86WRszU/66eP+aH7iAm4yxsMHhMPCIWFtYJfc=";
        }
        {
          name = "parse-tree";
          publisher = "pokey";
          version = "0.23.0";
          sha256 = "sha256-sFsYoHcwctesCzD5ItfnRPEop3WPV1eSvl642FcgzPk=";
        }
        {
          name = "talon";
          publisher = "pokey";
          version = "0.2.0";
          sha256 = "sha256-BPc0jGGoKctANP4m305hoG9dgrhjxZtFdCdkTeWh/Xk=";
        }
        {
          name = "vscode-direnv";
          publisher = "cab404";
          version = "1.0.0";
          sha256 = "sha256-+nLH+T9v6TQCqKZw6HPN/ZevQ65FVm2SAo2V9RecM3Y=";
        }
        {
          name = "gitlens";
          publisher = "eamodio";
          version = "13.0.3";
          sha256 = "sha256-4oLwcAR6sLjxCPZqI8s6JKO8AHLf7TeiZLB0/+/bjjI=";
        }
      ];
    };
  };
}
