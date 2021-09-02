{ config, pkgs, ... }:
let
  env_root = "/home/jan/Projects/env";
  unstable = import <nixos-unstable> { config = {allowUnfree = true; }; };
in let
  dotfiles = env_root + "/dotfiles";
  awesome-widgets = env_root + "/awesome-wm-widgets";
  json-lua = pkgs.fetchFromGitHub {
    owner = "rxi";
    repo = "json.lua";
    rev = "v0.1.2";
    sha256 = "sha256:0sgcf7x8nds3abn46p4fg687pk6nlvsi82x186vpaj2dbv28q8i5";
  };
  flowblade = (import (builtins.fetchTarball {
    url = "https://github.com/polygon/nixpkgs/archive/d68139154c0855636d4c1d553f382c1b4f7648ad.tar.gz";
    sha256 = "sha256:0rvk78y1b80mx750r8fg3jdlcm8j6fwr8mkis652s1mfwh4zsv3r";
  }) { } ).flowblade;
in
{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "jan";
  home.homeDirectory = "/home/jan";

  nixpkgs.overlays = [
    (self: super: {
      geeqie = unstable.geeqie;
      blender = unstable.blender;
      zsh-prezto = super.zsh-prezto.overrideAttrs (old: {
        patches = (old.patches or []) ++ [
          (/. + "${dotfiles}/zsh/0001-poly-prompt.patch")
        ];
      });
    } )
  ];

  services.redshift = {
    enable = true;
    latitude = "51.0";
    longitude = "13.7";
  };

  programs.firefox = {
    enable = true;
    profiles.myprofile.settings = {
      "general.smoothScroll" = true;
    };
  };

  programs.chromium.enable = true;

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
unsetopt NOMATCH
'';
    envExtra = ''
EDITOR=vim
'';
#    oh-my-zsh = {
#      enable = true;
#      plugins = [ "gitfast" "nix-zsh-completions" ];
#      custom = "${dotfiles}/zsh";
#      theme = "polygon";
#    };
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

  programs.tmux = {
    enable = true;
    baseIndex = 1;
    clock24 = true;
    historyLimit = 10000;
    terminal = "tmux-256color";
    extraConfig = ''
unbind C-b
set-option -g prefix C-a
bind-key C-a last-window
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
  home.file.".config/awesome/json".source = json-lua;
  home.file.".direnvrc".source = dotfiles + "/misc/direnvrc";

  home.packages = with pkgs; [
    hueadm
    gimp
    inkscape
    geeqie
    hexchat
    dino
    pavucontrol 
    nix-index
    steam
    acpi
    owncloud-client
    keepassx2
    xtrlock-pam
    brightnessctl
    gnome3.gnome-tweak-tool
    wget
    thunderbird
    spotify
    qjackctl
    xlibs.xhost
    htop
    vscodium
    mplayer
    vlc
    traceroute
    zeal
    element-desktop
    nixpkgs-review
    flowblade
    blender
  ];

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.03";
}
