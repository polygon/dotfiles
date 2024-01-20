# Test container to test testing stuff
{ config, pkgs, simple-nixos-mailserver, ... }:               
let
  persistent_mounts = {
    "/var/vmail" = { 
      hostPath = "/vms/mail/vmail";
      isReadOnly = false; 
    };

    "/var/lib/dovecot/indices" = {
      hostPath = "/vms/mail/indices";
      isReadOnly = false;
    };

    "/var/sieve" = {
      hostPath = "/vms/mail/sieve";
      isReadOnly = false; 
    };

    "/var/dkim" = {
      hostPath = "/vms/mail/dkim";
      isReadOnly = false;
    };

    "/var/lib/redis" = {
      hostPath = "/vms/mail/redis";
      isReadOnly = false;
    };

    "/var/lib/rspamd" = {
      hostPath = "/vms/mail/rspamd";
      isReadOnly = false;
    };
  };
  hostPaths = builtins.map (f: f.hostPath) (builtins.attrValues persistent_mounts);
in
{
  systemd.tmpfiles.rules = builtins.map (f: "d ${f} 755 root root") hostPaths;
  security.acme.certs."nubego.de".reloadServices = [ "container@mail.service" ];
  networking.nat = {
    internalInterfaces = [ "ve-mail" ];
    forwardPorts = [
      {
        sourcePort = 25;
        proto = "tcp";
        destination = "10.23.42.15:25";
      }
      {
        sourcePort = 143;
        proto = "tcp";
        destination = "10.23.42.15:143";
      }
      {
        sourcePort = 465;
        proto = "tcp";
        destination = "10.23.42.15:465";
      }
      {
        sourcePort = 587;
        proto = "tcp";
        destination = "10.23.42.15:587";
      }
      {
        sourcePort = 993;
        proto = "tcp";
        destination = "10.23.42.15:993";
      }
    ];
  };
  networking.firewall.allowedTCPPorts = [ 25 143 465 587 993 ];

  containers.mail = {
    ephemeral = true;
    autoStart = true;
    privateNetwork = true;
    hostAddress = "10.23.42.14";
    localAddress = "10.23.42.15";

    bindMounts = persistent_mounts // {
      "/var/lib/ssl/nubego" = {
        hostPath = config.security.acme.certs."nubego.de".directory;
        isReadOnly = true;
      };

      "/var/lib/secrets" = {
        hostPath = "/run/secrets/mail";
        isReadOnly = true;
      };
    };
    
    config = 
      { config, pkgs, lib, ... }:
      {
        imports = [ simple-nixos-mailserver.nixosModule ];
        environment.systemPackages = with pkgs; [
        ];

        networking = {
          nameservers = [ "1.1.1.1" ];
          useHostResolvConf = lib.mkForce false;
        };        

        mailserver = {
          enable = true;
          fqdn = "mail.nubego.de";
          domains = [ "nubego.de" ];

          loginAccounts = {
            "jan@nubego.de" = {
              hashedPasswordFile = "/var/lib/secrets/jan/hashedPasswordFile";
              aliases = [
                "postmaster@nubego.de"
                "abuse@nubego.de"
              ];
            };
          };

          certificateScheme = "manual";
          keyFile = "/var/lib/ssl/nubego/key.pem";
          certificateFile = "/var/lib/ssl/nubego/fullchain.pem";

          fullTextSearch.enable = true;

          # Pin folder to desired locations
          indexDir = "/var/lib/dovecot/indices";
          sieveDirectory = "/var/sieve";
          mailDirectory = "/var/vmail";
          dkimKeyDirectory = "/var/dkim";

          mailboxes = {
            Drafts = {
              auto = "subscribe";
              specialUse = "Drafts";
            };
            Junk = {
              auto = "subscribe";
              specialUse = "Junk";
            };
            Sent = {
              auto = "subscribe";
              specialUse = "Sent";
            };
            Trash = {
              auto = "no";
              specialUse = "Trash";
            };
          };

          hierarchySeparator = "/";
        };

        # Put rspamd controller WebUI on port 11333
        services.rspamd.workers."controller".bindSockets = [ "*:11333" ];
        networking.firewall.allowedTCPPorts = [ 11333 ];

        system.stateVersion = "23.11";
      };
  };
}
