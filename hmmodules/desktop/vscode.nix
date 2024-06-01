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
      #package = pkgs.vscodium;
      extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
        vadimcn.vscode-lldb
        rust-lang.rust-analyzer
        ms-vscode-remote.remote-ssh
        eamodio.gitlens
        serayuzgur.crates
        usernamehw.errorlens
        ms-vscode.hexeditor
        bierner.markdown-mermaid
        jnoortheen.nix-ide
        gruntfuggly.todo-tree
        #ms-python.python
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "vscode-direnv";
          publisher = "cab404";
          version = "1.0.0";
          sha256 = "sha256-+nLH+T9v6TQCqKZw6HPN/ZevQ65FVm2SAo2V9RecM3Y=";
        }
      ];
    };
  };
}
