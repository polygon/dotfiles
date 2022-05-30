{ config, pkgs, unstable, ... }:               
{
  services.nginx = {
    enable = true;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;
  };

  services.nginx.virtualHosts."paperless.matelab.de" = {
    locations."/" = {
      proxyPass = "http://192.168.3.22:28981";
      proxyWebsockets = true;
    };
  };
}
