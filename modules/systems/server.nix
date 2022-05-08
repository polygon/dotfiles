{ config, lib, pkgs, ... }:

with lib;

# Config that should be the same on all server machines

let
  cfg = config.modules.systems.server;
in
{
  options.modules.systems.server.enable = mkEnableOption "Linux Server";

  config = mkIf cfg.enable {
    modules.systems.base.enable = true;
    
    nix.trustedUsers = [ "admin" ];

    security.sudo.extraRules = [
      {
        users = [ "admin" ];
        commands = [ { command = "ALL"; options = [ "SETENV" "NOPASSWD" ]; } ];
      }
    ];

    networking.networkmanager.enable = false;    

    users.users.admin = {
      uid = 10000;
      isNormalUser = true;
      extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICGEKrCGXyHqD0jdTYVHnnScL9mhDU2PR9VyH7fu528J"
      ];
    };    

    environment.systemPackages = with pkgs; [
    ];

    programs.ssh = {
      startAgent = true;
      agentTimeout = null;
    }; 
  }; 
}
