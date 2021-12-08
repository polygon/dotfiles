{ self, config, lib, pkgs, aww, ... }:

with lib;

let
  cfg = config.modules.desktop.awesome;
  json-lua = pkgs.fetchFromGitHub {
    owner = "rxi";
    repo = "json.lua";
    rev = "v0.1.2";
    sha256 = "sha256:0sgcf7x8nds3abn46p4fg687pk6nlvsi82x186vpaj2dbv28q8i5";
  };  
in
{
  options.modules.desktop.awesome.enable = mkEnableOption "awesomeWM";

  config = mkIf cfg.enable {
    home.file.".config/awesome/rc.lua".source = "${self}/awesome/rc.lua";
    home.file.".config/awesome/theme.lua".source = "${self}/awesome/theme.lua";
    home.file.".config/awesome/awesome-wm-widgets".source = aww;
    home.file.".config/awesome/json".source = json-lua;

  };
}
