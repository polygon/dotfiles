{ config, pkgs, ... }:               
{
  services.mosquitto = {
    enable = true;
    listeners = [
      {
        address = "0.0.0.0";
        users."admin" = {
          passwordFile = config.sops.secrets.mosquitto-users-admin.path;
          acl = [
            "readwrite #"
          ];
        };
        users."hass" = {
          passwordFile = config.sops.secrets.mosquitto-users-hass.path;
          acl = [
            "readwrite #"
          ];
        };
        users."plugs" = {
          passwordFile = config.sops.secrets.mosquitto-users-plugs.path;
          acl = [
            "readwrite tele/#"
            "readwrite cmnd/#"
            "readwrite stat/#"
            "readwrite tasmota/#"
          ];
        };
      }
    ];
  };

  networking.firewall.allowedTCPPorts = [ 1883 ];
}
