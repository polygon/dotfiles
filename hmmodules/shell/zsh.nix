{ config, lib, pkgs, self, ... }:

with lib;

let cfg = config.modules.shell.zsh;
in {
  options.modules.shell.zsh.enable = mkEnableOption "zsh";

  config = mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      initExtra = ''
        # Make autosuggestions visible with Solarized color scheme
        ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=23'

        eval "$(direnv hook zsh)"
        unsetopt NOMATCH
      '';
      #      prezto = {
      #        enable = true;
      #        pmodules = [
      #          "environment"
      #          "terminal"
      #          "editor"
      #          "history"
      #          "directory"
      #          "spectrum"
      #          "utility"
      #          "syntax-highlighting"
      #          "history-substring-search"
      #          "autosuggestions"
      #          "git"
      #          "completion"
      #          "prompt"
      #        ];
      #        prompt.theme = "poly";
      #      };
      antidote = {
        enable = true;
        plugins = [
          "romkatv/powerlevel10k"
        ];

      };
      initExtraBeforeCompInit = ''
        [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

        zstyle ':completion:*' menu select=3
      '';
      initExtraFirst = ''
        if [[ -r "$HOME/.cache/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "$HOME/.cache/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
      '';
      autosuggestion.enable = true;
      enableCompletion = true;
    };
    home.file.".p10k.zsh".source = "${self}/zsh/p10k.zsh";
  };
}
