{ self, config, pkgs, unstable, audio, ...
}:
{
  imports = [ ./common.nix ];

  home.packages = with pkgs; [
    blender-bin
    stellarium
    #siril
    ghidra
    cutter
  ];
}
