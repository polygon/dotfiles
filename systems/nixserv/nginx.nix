{ config, pkgs, unstable, ... }:               
{
  services.nginx = {
    enable = true;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;
    sslDhparam = "${config.security.dhparams.params."nginx".path}";
  };

  services.nginx.virtualHosts."paperless.matelab.de" = {
    useACMEHost = "matelab.de";
    forceSSL = true;

    locations."/" = {
      proxyPass = "http://192.168.3.22:28981";
      proxyWebsockets = true;
    };
  };

  services.nginx.virtualHosts."hab.matelab.de" = {
    useACMEHost = "matelab.de";
    forceSSL = true;

    locations."/log/" = {
      proxyPass = "http://192.168.3.10:9001";
      proxyWebsockets = true;
    };

    locations."/red/" = {
      proxyPass = "http://192.168.3.10:1880/";
      proxyWebsockets = true;
    };

    locations."/" = {
      proxyPass = "http://192.168.3.10:8080";
    };
  };

  services.nginx.virtualHosts."grafana.matelab.de" = {
    useACMEHost = "matelab.de";
    forceSSL = true;

    locations."/" = {
      proxyPass = "http://192.168.3.12:3000";
    };
  };

  # Allow nginx access to letsencrypt keys
  users.users."nginx".extraGroups = [ "acme" ];

  # Create DH Params
  security.dhparams.enable = true;
  security.dhparams.params."nginx".bits = 4096;

  # Open firewall for HTTP, HTTPS
  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
