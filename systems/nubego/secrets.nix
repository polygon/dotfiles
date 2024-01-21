{ config, secrets, ... }:
{
  sops.defaultSopsFile = "${secrets}/hosts/nubego/secrets.yaml";
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.gnupg.sshKeyPaths = [ ];
  sops.secrets = {
    cloudflare-dns-api-token = {
      owner = "acme";
      mode = "0400";
    };
    "mail/jan/hashedPasswordFile" = {
      restartUnits = [ "container@mail.service" ];
     };
    "dav/htpasswd" = {
      restartUnits = [ "container@dav.service" ];
    };
  };
}
