# WebDAV container, mainly Radicale
{ config, pkgs, ... }:               
{
  containers.dav = {
    ephemeral = true;
    autoStart = true;
    privateNetwork = true;
    hostAddress = "10.23.42.16";
    localAddress = "10.23.42.17";
    
    bindMounts = {
      "/var/lib/radicale/collections" = {
        hostPath = "/vms/dav/radicale";
        isReadOnly = false;
      };
      "/var/lib/secrets" = {
        hostPath = "/run/secrets/dav";
        isReadOnly = true;
      };      
    };

    config = 
      { config, pkgs, lib, ... }:
      {
        services.radicale = {
          enable = true;
          settings = {
            server = {
              hosts = [ "0.0.0.0:5232" ];
            };
            auth = {
              type = "htpasswd";
              htpasswd_filename = "/run/radicale/secrets/htpasswd";
              htpasswd_encryption = "bcrypt";
            };
            storage = {
              filesystem_folder = "/var/lib/radicale/collections";
            };
          };
        };

        systemd.services.radicale.serviceConfig.ExecStartPre = lib.mkBefore [
          "+${pkgs.coreutils}/bin/install --owner=radicale --mode=400 -D -T /var/lib/secrets/htpasswd /run/radicale/secrets/htpasswd"
        ];

        networking.firewall.allowedTCPPorts = [ 5232 ];

        system.stateVersion = "23.11";
      };
  };
}
