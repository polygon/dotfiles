{ config, pkgs, mqtt2psql, ... }:
{
  systemd.services.mqtt2psql = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      # Environment options
      Environment = [
        "MQTT_HOST=192.168.3.23"
        "MQTT_USER=plugs"
        "PSQL_HOST=192.168.3.20"
        "PSQL_USER=iot"
        "PSQL_DB=iot"
      ];
      EnvironmentFile = [
        config.sops.secrets.mqtt2psql-mqtt-pass.path
        config.sops.secrets.mqtt2psql-psql-pass.path
      ];
      # Service options
      ExecStart = "${mqtt2psql.packages.x86_64-linux.mqtt2psqlbin}";
      Restart = "on-failure";
      RestartSec = "5s";
      # Some default hardening
      DynamicUser = true;
      DeviceAllow = [ "" ];
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      PrivateDevices = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "invisible";
      RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
    };
  };
}
