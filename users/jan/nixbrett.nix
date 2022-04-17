{ self, config, pkgs, unstable, audio, ...
}:
{
  imports = [ ./common.nix ];

  audio.drumkits.shittyKit.enable = true;
  audio.vst.rvxx.enable = true;

  home.packages = with pkgs; [
    steam
    blender
    reaper
    drumgizmo
    patchage
    carla
  ];
}
