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
    matchers."MQTTBRIDGEPWD".secret = config.sops.secrets.mqttbridge.path;
    owner = "mosquitto";
    group = "mosquitto";
    mode = "0440";
  };
}
