{ config, secrets, ... }:
{
  sops.defaultSopsFile = "${secrets}/hosts/hal/secrets.yaml";
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.gnupg.sshKeyPaths = [ ];
  sops.secrets = let
    mqtt_perm = {
      owner = "mosquitto";
      group = "mosquitto";
      mode = "0440";
    };
    hass_perm = {
      owner = "hass";
      group = "hass";
      mode = "0440";
    };
  in
  {
    mosquitto-users-admin = mqtt_perm;
    mosquitto-users-plugs = mqtt_perm;
    mosquitto-users-hass = mqtt_perm;
    mosquitto-bridge-pi-username = { };
    mosquitto-bridge-pi-password = { };
    mqtt2psql-mqtt-pass = { };
    mqtt2psql-psql-pass = { };
    hass-psql-pass = { };
    hass-gotify-token = hass_perm;
    hass-lat = hass_perm;
    hass-lon = hass_perm;
  };
}
