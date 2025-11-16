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
      distrho-ports
      geonkick
      x42-plugins    
      dragonfly-reverb
      faustPhysicalModeling
      quadrafuzz
      calf
      lsp-plugins
      carla
      drumgizmo
      bitwig-studio-latest
      bespokesynth
      sonic-visualiser
      zenity
      stochas
      xtuner
      atlas2
      #plugdata
      #yabridge
      #yabridgectl
      wineWowPackages.full
      winetricks
      paulxstretch
      vital
      #run-scaled // deprecated, now part of xpra
      tony
      #neuralnote
      amplocker
      chow-tape-model
      #chow-multitool
      chow-centaur
      chow-phaser
      chow-kick
      papu
      kmidimon
      ripplerx
      aida-x
    ];

    security.pam.loginLimits = [
      { domain = "@audio"; item = "memlock"; type = "-"   ; value = "unlimited"; }
      { domain = "@audio"; item = "rtprio" ; type = "-"   ; value = "99"       ; }
      { domain = "@audio"; item = "nofile" ; type = "soft"; value = "99999"    ; }
      { domain = "@audio"; item = "nofile" ; type = "hard"; value = "99999"    ; }
    ];

    services.udev.extraRules = ''
      KERNEL=="rtc0", GROUP="audio"
      KERNEL=="hpet", GROUP="audio"
    '';
  };
}
