{ config, lib, pkgs, ... }:

with lib;

let cfg = config.modules.wireguard.wacken;
in {
  options.modules.wireguard.wacken.enable = mkEnableOption "Wacken";

  config = mkIf cfg.enable {
    #    networking.wg-quick = {
    #      interfaces = {
    #        wacken = {
    #          address = [ "192.168.32.3/24" ];
    #          privateKeyFile = "/home/jan/wg/private";
    #          peers = [
    #            {
    #              publicKey = "QyuTtKOx3qljMd7rMo7zFcs3rW7pU5zhMs+nUC6AnR8=";
    #              allowedIPs = [ "192.168.32.0/24" "192.168.1.0/24" "192.168.2.0/24" "192.168.3.0/24" ];
    #              endpoint = "wacken.matelab.de:48573";
    #              persistentKeepalive = 25; 
    #            }
    #          ];
    #        };
    #      };
    systemd.network = {
      netdevs."50-wackenwg" = {
        netdevConfig = {
          Kind = "wireguard";
          Name = "wackenwg";
        };
        wireguardConfig = {
          PrivateKeyFile = "/etc/wireguard/private";
          RouteTable = "main";
        };
        wireguardPeers = [{
          PublicKey = "QyuTtKOx3qljMd7rMo7zFcs3rW7pU5zhMs+nUC6AnR8=";
          Endpoint = "wacken.matelab.de:48573";
          PersistentKeepalive = 25;
          AllowedIPs = [
            "192.168.32.0/24"
            "192.168.1.0/24"
            "192.168.2.0/24"
            "192.168.3.0/24"
          ];
        }];
      };

      networks."50-wackenwg" = {
        matchConfig.Name = "wackenwg";
        address = [ "192.168.32.3/24" ];
        dns = [ "192.168.32.1" ];
        domains = [ "~matelab.de" ];
        networkConfig.DNSDefaultRoute = false;
        linkConfig = {
          ActivationPolicy = "manual";
          RequiredForOnline = "no";
        };
      };
    };
    # Do not autostart wg-quick interfaces
    #    systemd.services.wg-quick-wacken.wantedBy = pkgs.lib.mkForce [ ];

    #  networking.firewall.allowedUDPPorts = [ 48573 ];

    #    modules.wireguard.enable = true;
  };

}
