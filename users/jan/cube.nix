{ self, config, pkgs, unstable, audio, ...
}:
{
  imports = [ ./common.nix ];

  #audio.drumkits.shittyKit.enable = true;
  #audio.vst.rvxx.enable = true;

  modules.desktop.awesome.enable = false;

  home.packages = with pkgs; [
    steam
    steam-run
    blender
    reaper
    patchage
    carla
    stellarium
    siril
    bespokesynth
  ];

  home.stateVersion = "22.11";
}
