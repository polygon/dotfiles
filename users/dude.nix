{ config, pkgs, unstable, ... }:
{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "dude";
  home.homeDirectory = "/home/dude";

  modules.desktop.firefox.enable = true;
  modules.shell.tmux.enable = true;
  modules.shell.zsh.enable = true;
  modules.shell.vim.enable = true;
  modules.shell.git.enable = true;

  home.packages = with pkgs; [
    geeqie
    (mplayer.override { pulseSupport = true; })
    filezilla
    keepassxc
    nmap
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
