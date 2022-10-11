{ self, config, pkgs, unstable, audio, ...
}:
{
  imports = [ ./common.nix ];

  audio.drumkits.shittyKit.enable = true;
  audio.vst.rvxx.enable = true;

  home.packages = with pkgs; [
    steam
    steam-run
    blender
    reaper
    drumgizmo
    patchage
    carla
    stellarium
    siril
  ];
}
