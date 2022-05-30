# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, unstable, ... }:
{
  # == Module Configuration ==

  modules.systems.microvm.enable = true;

  networking = {
    domain = "matelab.de";
    dhcpcd.enable = false;
    useNetworkd = true;
  };

  systemd.services.systemd-networkd-wait-online.enable = false;
  systemd.network = {
    enable = true;
    # Configure bridges for networks that we want the host to have access to
    networks."lan" = {
      matchConfig.MACAddress = "ba:da:55:01:00:00";
      addresses = [ { 
        addressConfig.Address = "192.168.1.22/24";
      } ];
      networkConfig = {
        Gateway = "192.168.1.1";
        DNS = "192.168.1.1";
      };
    };
    networks."server" = {
      matchConfig.MACAddress = "ba:da:55:01:00:01";
      addresses = [ { 
        addressConfig.Address = "192.168.3.22/24";
      } ];
    };
  };

  services.resolved.enable = true;
  services.paperless.address = "192.168.3.22";
  services.paperless.enable = true;
  services.paperless.extraConfig = {
    PAPERLESS_FILENAME_FORMAT = "{created_year}/{correspondent}/{created_month}-{created_day}-{title}-{asn}";
    PAPERLESS_OCR_LANGUAGE = "deu+eng";
    PAPERLESS_OCR_MODE = "skip";
    PAPERLESS_OCR_CLEAN = "clean";
    PAPERLESS_TASK_WORKERS = 2;
    PAPERLESS_THREADS_PER_WORKER = 2;
    PAPERLESS_TIME_ZONE = "Europe/Berlin";
  };

  networking.firewall.allowedTCPPorts = [ 28981 ];

  environment.systemPackages = with pkgs; [
    ripgrep
  ];

  environment.noXlibs = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}

