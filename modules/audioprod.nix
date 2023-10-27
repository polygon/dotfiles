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

    # Ableton link
    networking.firewall.allowedUDPPorts = [ 20808 ];

    environment.pathsToLink = [ "/lib/vst2" "/lib/vst3" "/lib/clap" ];

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
      bitwig-studio5-latest
      #bitwig-studio5-stable-latest
      bespokesynth
      sonic-visualiser
      gnome.zenity
      stochas
      xtuner
      atlas2
      plugdata
      yabridge
      yabridgectl
      wineWowPackages.full
      winetricks
      paulxstretch
      vital
      run-scaled
      tony
    ];
  };
}
