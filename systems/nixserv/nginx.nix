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

  # Allow nginx access to letsencrypt keys
  users.users."nginx".extraGroups = [ "acme" ];

  # Create DH Params
  security.dhparams.enable = true;
  security.dhparams.params."nginx".bits = 4096;

  # Open firewall for HTTP, HTTPS
  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
