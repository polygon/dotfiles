{lib, config, prev, ...}:
let
  start = "${prev.config.systemd.services.mosquitto.serviceConfig.ExecStart}";
  mosquitto_cfgfile = builtins.head (builtins.match ".*-c ([^[:space:]]+)" "${start}");
in
{
  systemd.services.mosquitto.serviceConfig.ExecStart = lib.mkForce (
    builtins.replaceStrings [ "${mosquitto_cfgfile}" ] [ "${config.scalpel.trafos."mosquitto.conf".destination} "] "${start}"
  );
  scalpel.trafos."mosquitto.conf" = {
    source = mosquitto_cfgfile;
    matchers."BRIDGE_PI_USERNAME".secret = config.sops.secrets.mosquitto-bridge-pi-username.path;
    matchers."BRIDGE_PI_PASSWORD".secret = config.sops.secrets.mosquitto-bridge-pi-password.path;
    owner = "mosquitto";
    group = "mosquitto";
    mode = "0440";
  };
}
