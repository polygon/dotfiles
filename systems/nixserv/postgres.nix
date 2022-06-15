{ config, pkgs, ... }:               
{
  # Common config
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_14;
    enableTCPIP = true;
    extraPlugins = with pkgs.postgresql14Packages; [
      timescaledb
    ];
    settings = {
      listen_addresses = pkgs.lib.mkForce "localhost,192.168.3.20";
      shared_preload_libraries = "timescaledb";
    };
    authentication = ''
      host  all all 192.168.3.0/24 md5
    '';

    ensureDatabases = [
      "paperless"
      "iot"
    ];

    ensureUsers = [
      {
        name = "paperless";
        ensurePermissions = {
          "DATABASE \"paperless\"" = "ALL PRIVILEGES";
        };
      }
      {
        name = "iot";
        ensurePermissions = {
          "DATABASE \"iot\"" = "ALL PRIVILEGES";
        };
      }
    ];
  };

  # Open firewall for Postgres
  networking.firewall.allowedTCPPorts = [ 5432 ];
}
