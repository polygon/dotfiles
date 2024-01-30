# File synchronization through syncthing
{ config, pkgs, secrets, self, ... }:               
{
  networking.nat = {
    internalInterfaces = [ "ve-sync" ];
    forwardPorts = [
      {
        sourcePort = 22000;
        proto = "tcp";
        destination = "10.23.42.19:22000";
      }
      {
        sourcePort = 22000;
        proto = "udp";
        destination = "10.23.42.19:22000";
      }
    ];
  };

  containers.sync = {
    ephemeral = true;
    autoStart = true;
    privateNetwork = true;
    hostAddress = "10.23.42.18";
    localAddress = "10.23.42.19";
    
    bindMounts = {
      "/var/lib/syncthing" = {
        hostPath = "/vms/sync/syncthing";
        isReadOnly = false;
      };    
    };

    specialArgs = { inherit self secrets; };
    
    config = 
      { config, pkgs, lib, ... }:
      {
        imports = [ "${self}/modules/syncthing.nix" ];

        modules.apps.syncthing = {
          enable = true;
          basePath = "/var/lib/syncthing";
          guiAddress = "0.0.0.0:8384";
          includeAddresses = false;
        };

        users.users.jan = {
          isNormalUser = true;
          uid = 1000;
        };

        networking.firewall.allowedTCPPorts = [ 8384 ];

        system.stateVersion = "23.11";
      };
  };
}
