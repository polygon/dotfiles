{ config, pkgs, ... }:               
{
  services.mosquitto = {
    enable = true;
    listeners = [
      {
        address = "0.0.0.0";
        users."admin" = {
          passwordFile = "/var/lib/secrets/mqtt/admin";
          acl = [
            "readwrite #"
          ];
        };
        users."plugs" = {
          passwordFile = "/var/lib/secrets/mqtt/plugs";
          acl = [
            "readwrite plugs/#"
            "readwrite tasmota/#"
          ];
        };
      }
    ];

    bridges.pi = {
      addresses = [ { address = "192.168.3.10"; } ];
      topics = [ "plugs/# in" "tasmota/# in" ];
    };
  };

  networking.firewall.allowedTCPPorts = [ 1883 ];
}
