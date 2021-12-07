{ config, pkgs, unstable, ... }:
{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "dude";
  home.homeDirectory = "/home/dude";

  programs.firefox = {
    enable = true;
    profiles.myprofile.settings = {
      "general.smoothScroll" = true;
    };
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
    envExtra = ''
      EDITOR=vim;
    '';

    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
    };
  };

  home.packages = with pkgs; [
    geeqie
    mplayer
    filezilla
    keepassx
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
