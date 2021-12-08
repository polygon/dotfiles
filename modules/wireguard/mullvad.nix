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
          address = [ "10.67.204.250/32" "fc00:bbbb:bbbb:bb01::4:ccf9/128" ];
          privateKeyFile = "/home/jan/wg/private";
          postUp = "systemd-resolve -i mullvad --set-dns=193.138.218.74 --set-domain=~.";
          peers = [
            { 
              publicKey = "+30LcSQzgNtB01wyCyh4YPjItVyBFX5TP6Fs47AJSnA=";
              allowedIPs = [ "0.0.0.0/0" "::0/0" ];
              endpoint = "de10-wireguard.mullvad.net:51820";
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
