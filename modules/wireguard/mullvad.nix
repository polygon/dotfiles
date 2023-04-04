{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.wireguard.mullvad;
in
{
  options.modules.wireguard.mullvad.enable = mkEnableOption "Mullvad";

  config = mkIf cfg.enable {
    networking.wg-quick = {
      interfaces = {
        mullvad = {
          address = [ "10.65.0.99/32" "fc00:bbbb:bbbb:bb01::2:62/128" ];
          privateKeyFile = "/home/jan/wg/private";
          postUp = "systemd-resolve -i mullvad --set-dns=193.138.218.74 --set-domain=~.";
          peers = [
            { 
              publicKey = "9ldhvN7r4xGZkGehbsNfYb5tpyTJ5KBb5B3TbxCwklw=";
              allowedIPs = [ "0.0.0.0/0" "::0/0" ];
              endpoint = "146.70.117.34:51820";
              persistentKeepalive = 25;
            }
          ];
        };
      };
    };

    # Do not autostart wg-quick interfaces
    systemd.services.wg-quick-mullvad.wantedBy = pkgs.lib.mkForce [ ];

    networking.firewall.allowedUDPPorts = [ 51820 ];

    modules.wireguard.enable = true;
  };
}
