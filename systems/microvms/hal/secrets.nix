{ config, secrets, ... }:
{
  sops.defaultSopsFile = "${secrets}/hosts/hal/secrets.yaml";
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.gnupg.sshKeyPaths = [ ];
  sops.secrets = let
    permissions = {
      owner = "mosquitto";
      group = "mosquitto";
      mode = "0440";
    };
  in
  {
    mosquitto-users-admin = permissions;
    mosquitto-users-plugs = permissions;
    mosquitto-bridge-pi-username = { };
    mosquitto-bridge-pi-password = { };
  };
}