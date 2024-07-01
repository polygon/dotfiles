{ config, pkgs, unstable, ... }:
{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "midimaxe";
  home.homeDirectory = "/home/midimaxe";

  modules.desktop.firefox.enable = true;
  modules.shell.tmux.enable = true;
  modules.shell.zsh.enable = true;
  modules.shell.vim.enable = true;

  modules.desktop.awesome.enable = pkgs.lib.mkDefault true;
  modules.desktop.gnome-terminal.enable = true;

  home.packages = with pkgs; [
  ];

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.05";
}
