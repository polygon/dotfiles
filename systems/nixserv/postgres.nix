{ config, pkgs, ... }:               
{
  # Common config
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_14;
    enableTCPIP = true;
    settings = {
      listen_addresses = pkgs.lib.mkForce "localhost,192.168.3.20";
    };
    authentication = ''
      host  all all 192.168.3.0/24 md5
    '';

    ensureDatabases = [
      "paperless"
    ];

    ensureUsers = [
      {
        name = "paperless";
        ensurePermissions = {
          "DATABASE \"paperless\"" = "ALL PRIVILEGES";
        };
      }
    ];
  };

  # Open firewall for Postgres
  networking.firewall.allowedTCPPorts = [ 5432 ];
}
