{ self, config, pkgs, unstable, audio, ...
}:
{
  imports = [ ./common.nix ];

  home.packages = with pkgs; [
    blender
    stellarium
    #siril
    ghidra
    cutter
  ];
}
