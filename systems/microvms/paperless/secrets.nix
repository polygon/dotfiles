{ config, secrets, ... }:
{
  sops.defaultSopsFile = "${secrets}/hosts/paperless/secrets.yaml";
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.gnupg.sshKeyPaths = [ ];
  sops.secrets = let
    permissions = {
      owner = "paperless";
      group = "paperless";
      mode = "0440";
    };
  in
  {
    paperless-dbpass = permissions;
    paperless-dbpass-envfile = permissions;
  };
}