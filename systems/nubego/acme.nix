{ config, pkgs, unstable, ... }:               
{
  security.acme = {
    acceptTerms = true;
    defaults.email = "polygon@wh2.tu-dresden.de";
    certs."nubego.de" = {
      dnsProvider = "cloudflare";
      dnsResolver = "1.1.1.1:53";
      credentialFiles."CLOUDFLARE_DNS_API_TOKEN_FILE" = "/run/secrets/cloudflare-dns-api-token";
      dnsPropagationCheck = true;
      domain = "nubego.de";
      extraDomainNames = [ "*.nubego.de" ];
      reloadServices = [ ];
    };
  };
}
