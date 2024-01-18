# Test container to test testing stuff
{ config, pkgs, ... }:               
{
  containers.playground = {
    ephemeral = true;
    autoStart = true;
    privateNetwork = true;
    hostAddress = "10.23.42.10";
    localAddress = "10.23.42.11";
    
    config = 
      { config, pkgs, lib, ... }:
      {
        networking = {
          nameservers = [ "1.1.1.1" ];
          useHostResolvConf = lib.mkForce false;
        };
        system.stateVersion = "23.11";
      };
  };
}
