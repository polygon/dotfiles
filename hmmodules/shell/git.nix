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
      settings = {
        user.name = "polygon";
        user.email = "polygon@wh2.tu-dresden.de";
        init = {
          defaultBranch = "main";
        };
      };
    };

    programs.difftastic = {
      enable = true;
      git.enable = true;
    };
  };
}
