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
    reaper
    blender-bin
    patchage
    stellarium
    siril
  ];

  home.stateVersion = "22.11";
}
