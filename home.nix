{ config, pkgs, ... }:
let
  project_root = "/home/jan/Projects";
in let
  dotfiles = project_root + "/dotfiles";
  awesome-widgets = project_root + "/awesome-wm-widgets";
in
{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "jan";
  home.homeDirectory = "/home/jan";

  programs.firefox = {
    enable = true;
    profiles.myprofile.settings = {
      "general.smoothScroll" = true;
    };
  };

  programs.git = {
    enable = true;
    userName = "polygon";
    userEmail = "polygon@wh2.tu-dresden.de";
  };

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

  programs.zsh = {
    enable = true;
    initExtra = ''
eval "$(direnv hook zsh)"
'';
    envExtra = ''
EDITOR=vim
'';
    oh-my-zsh = {
      enable = true;
      plugins = [ "gitfast" ];
      custom = "${dotfiles}/zsh";
      theme = "polygon";
    };
  };

  programs.tmux = {
    enable = true;
    baseIndex = 1;
    clock24 = true;
    historyLimit = 10000;
    prefix = "C-a";
    terminal = "tmux-256color";
    extraConfig = ''
bind-key C-a last-window
bind-key a send-prefix
set-option -g set-titles on
set-option -g set-titles-string '#H:#S.#I.#P #W #T'
setw -g monitor-activity on
set-option -g status-justify left
set-option -g status-bg yellow
set-option -g status-fg black
'';
  };

  nixpkgs.config.allowUnfree = true;

  # Awesome config
  home.file.".config/awesome/rc.lua".source = dotfiles + "/awesome/rc.lua";
  home.file.".config/awesome/theme.lua".source = dotfiles + "/awesome/theme.lua";
  home.file.".config/awesome/awesome-wm-widgets".source = builtins.filterSource 
    (path: type: type != "directory" || baseNameOf path != ".git")
    awesome-widgets;

  home.packages = with pkgs; [
    direnv
    gimp
    pavucontrol 
    steam
    acpi
    owncloud-client
    keepassx2
    xtrlock-pam
  ];

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.05";
}
