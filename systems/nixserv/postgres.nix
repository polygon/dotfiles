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
      listen_addresses = pkgs.lib.mkForce "localhost,192.168.3.20,192.168.1.20";
      shared_preload_libraries = "timescaledb";
    };
    authentication = ''
      host  all all 192.168.3.0/24 md5
      host  all all 192.168.1.0/24 md5
    '';

    ensureDatabases = [
      "paperless"
      "iot"
      "hass"
    ];

    ensureUsers = [
      {
        name = "paperless";
        ensureDBOwnership = true;
      }
      {
        name = "iot";
        ensureDBOwnership = true;
      }
      {
        name = "hass";
        ensureDBOwnership = true;
      }
    ];
  };

  # Open firewall for Postgres
  networking.firewall.allowedTCPPorts = [ 5432 ];
}
