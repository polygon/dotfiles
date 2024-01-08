{ config, pkgs, unstable, ... }:               
{
  services.nginx = {
    enable = true;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;
    sslDhparam = "${config.security.dhparams.params."nginx".path}";
    defaultListenAddresses = [ "45.129.180.166" ];
  };

  services.nginx.virtualHosts."new.nubego.de" = {
    useACMEHost = "nubego.de";
    forceSSL = true;
    root = "${pkgs.nginx}/html";
  };

  services.nginx.virtualHosts."push.nubego.de" = {
    useACMEHost = "nubego.de";
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://10.23.42.13:8080/";
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
