{ config, pkgs, unstable, ... }:               
{
  security.acme = {
    acceptTerms = true;
    defaults.email = "polygon@wh2.tu-dresden.de";
    certs."matelab.de" = {
      dnsProvider = "cloudflare";
      dnsResolver = "1.1.1.1:53";
      credentialFiles."CLOUDFLARE_DNS_API_TOKEN_FILE" = "/var/lib/secrets/matelab-cloudflare-api-token";
      dnsPropagationCheck = true;
      domain = "matelab.de";
      extraDomainNames = [ "*.matelab.de" ];
      reloadServices = [ "nginx" ];
    };
  };
}
