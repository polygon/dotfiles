{ config, lib, pkgs, ... }:

with lib;

# Base config for all Linux systems

let
  cfg = config.modules.apps.audioprod;
in
{
  options.modules.apps.audioprod.enable = mkEnableOption "Audio Production Applications";

  config = mkIf cfg.enable {
    environment.variables = {
      LV2_PATH = "/run/current-system/sw/lib/lv2";
    };

    environment.systemPackages = with pkgs; [
      distrho
      geonkick
      x42-plugins    
      dragonfly-reverb
      faustPhysicalModeling
      quadrafuzz
      calf
      lsp-plugins
      carla
      drumgizmo
      bitwig-studio
      bespokesynth
      sonic-visualiser
      gnome.zenity
      stochas
      xtuner
      atlas2
      plugdata
    ];
  };
}
