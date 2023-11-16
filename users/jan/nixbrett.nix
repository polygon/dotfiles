{ self, config, pkgs, unstable, audio, ...
}:
{
  imports = [ ./common.nix ];

  home.packages = with pkgs; [
    steam
    steam-run
    blender
    stellarium
    siril
    ghidra
    cutter
    AusweisApp2
  ];
}
