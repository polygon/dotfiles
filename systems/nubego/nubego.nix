# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, unstable, ... }:
{
  # == Module Configuration ==

  modules.systems.server.enable = true;

  # ZFS related options
  boot.kernelParams = [ "nohibernate" ];
  boot.initrd.supportedFilesystems = [ "zfs" ];
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.extraPools = [ "bpool" "rpool" ];
  boot.zfs.devNodes = "/dev/disk/by-partuuid";

  # Grub
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;


  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="vd[a-z]*[0-9]*|sd[a-z]*[0-9]*|mmcblk[0-9]*p[0-9]*|nvme[0-9]*n[0-9]*p[0-9]*", ENV{ID_FS_TYPE}=="zfs_member", ATTR{../queue/scheduler}="none"
  ''; # zfs already has its own scheduler. without this my(@Artturin) computer froze for a second when i nix build something.  

  # Automatic ZFS maintenance
  services.zfs = {
    autoScrub.enable = true;
    trim.enable = true;
  };

  networking = {
    hostName = "nubego";
    domain = "nubego.de";
    hostId = "bd66481d";
    dhcpcd.enable = false;
    nat = {
      externalInterface = "ens3";
      enable = true;
    };
  };

  systemd.services.systemd-networkd-wait-online.enable = pkgs.lib.mkForce false;
  systemd.network = {
    enable = true;
    
    networks."10-wan" = {
      matchConfig.Name = "ens3";
      networkConfig = {
        DHCP = "ipv4";
        IPv6AcceptRA = true;
      };
    };
    networks."10-ve" = {
      matchConfig.Name = "ve*";
      networkConfig = {
        DHCP = "no";
      };
    };
  };

  # Extra user accounts (mainly for NFS)
  users.users.jan = {
    isNormalUser = true;
    uid = 1000;
  };

  # Public facing server, put a bit more SSH security in place
   services.openssh = {
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.

  services.resolved.enable = true;

  security.dhparams.stateful = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}

