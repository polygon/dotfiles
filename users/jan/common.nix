{ self
, config
, pkgs
, unstable
, aww
, audio
, ...
}:
{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "jan";
  home.homeDirectory = "/home/jan";

  #programs.chromium.enable = true;

  modules.shell.common.enable = true;
  modules.shell.tmux.enable = true;
  modules.shell.zsh.enable = true;
  modules.shell.vim.enable = true;
  modules.shell.git.enable = true;

  modules.desktop.awesome.enable = pkgs.lib.mkDefault true;
  modules.desktop.gammastep.enable = true;
  modules.desktop.firefox.enable = true;
  modules.desktop.gnome-terminal.enable = true;
  modules.desktop.vscode.enable = true;

  nixpkgs.config.allowUnfree = true;

  # Awesome config
  #home.file.".direnvrc".source = "${self}/misc/direnvrc";

  home.packages = with pkgs; [
    hueadm
    gimp-with-plugins
    inkscape
    geeqie
    hexchat
    dino
    pavucontrol
    acpi
    owncloud-client
    keepassxc
    brightnessctl
    gnome.gnome-tweaks
    thunderbird
    spotify
    qjackctl
    xorg.xhost
    mplayer
    vlc
    zeal
    element-desktop
    nixpkgs-review
    flowblade
    nixpkgs-fmt
    freecad
    prusa-slicer
    imagemagick
    xfce.thunar
    ncdu
    clementine
  ];

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = pkgs.lib.mkDefault "21.03";
}
