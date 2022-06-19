{ config, secrets, ... }:
{
  sops.defaultSopsFile = "${secrets}/hosts/hal/secrets.yaml";
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.gnupg.sshKeyPaths = [ ];
  sops.secrets = {
    mosquitto-users-admin = { };
    mosquitto-users-plugs = { };
    mosquitto-bridge-pi-username = { };
    mosquitto-bridge-pi-password = { };
  };
}