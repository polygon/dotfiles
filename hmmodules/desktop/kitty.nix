{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.desktop.kitty;
in
{
  options.modules.desktop.kitty.enable = mkEnableOption "kitty";

  config = mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      font = {
        name = "MesloLGS NF";
        size = 11;
      };
      settings = {
        background = "#002b36";
        foreground = "#839496";

        # Palette (Solarized Dark)
        color0 = "#073642";
        color1 = "#dc322f";
        color2 = "#859900";
        color3 = "#b58900";
        color4 = "#268bd2";
        color5 = "#d33682";
        color6 = "#2aa198";
        color7 = "#eee8d5";
        color8 = "#002b36";
        color9 = "#cb4b16";
        color10 = "#586e75";
        color11 = "#657b83";
        color12 = "#839496";
        color13 = "#6c71c4";
        color14 = "#93a1a1";
        color15 = "#fdf6e3";
      };
    };
  };
}
