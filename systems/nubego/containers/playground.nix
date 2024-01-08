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
      { config, pkgs, ... }:
      {
        system.stateVersion = "23.11";
      };
  };
}
