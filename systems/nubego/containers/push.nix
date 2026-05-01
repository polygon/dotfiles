# Test container to test testing stuff
{ config, pkgs, ... }:               
{
  containers.push = {
    ephemeral = true;
    autoStart = true;
    privateNetwork = true;
    hostAddress = "10.23.42.12";
    localAddress = "10.23.42.13";

    bindMounts = {
      "/var/lib/private/push" = { 
        hostPath = "/vms/push";
        isReadOnly = false; 
      };
    };
    
    config = 
      { config, pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          sqlite
          kitty.terminfo
        ];

        services.gotify = {
          enable = true;
          stateDirectoryName = "push";
          environment.GOTIFY_SERVER_PORT = 8080;
        };

        # Open firewall for reverse proxy
        networking.firewall.allowedTCPPorts = [ 8080 ];

        system.stateVersion = "23.11";
      };
  };
}
