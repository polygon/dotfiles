{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.shell.zsh;
in
{
  options.modules.shell.zsh.enable = mkEnableOption "zsh";

  config = mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      initExtra = ''
        eval "$(direnv hook zsh)"
        unsetopt NOMATCH
      '';
      prezto = {
        enable = true;
        pmodules = [
          "environment"
          "terminal"
          "editor"
          "history"
          "directory"
          "spectrum"
          "utility"
          "syntax-highlighting"
          "history-substring-search"
          "autosuggestions"
          "git"
          "completion"
          "prompt"
        ];
        prompt.theme = "poly";
      };
    };
  };
}
