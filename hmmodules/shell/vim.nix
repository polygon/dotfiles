{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.shell.vim;
in
{
  options.modules.shell.vim.enable = mkEnableOption "vim";

  config = mkIf cfg.enable {
    programs.vim = {
      enable = true;
      settings = {
        expandtab = false;
        shiftwidth = 2;
        tabstop = 2;
      };
      extraConfig = ''
        set cindent
        set smartindent
        set autoindent
        set foldmethod=syntax
        nmap <F2> zA
        nmap <F3> zR
        nmap <F4> zM
        syntax enable
      '';
    };

    home.sessionVariables = {
      EDITOR = "vim";
    };

    programs.git.includes = [
      { contents = { core.editor = "vim"; }; }
    ];
  };
}
