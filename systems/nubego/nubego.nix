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
    useNetworkd = true;
  };

  systemd.services.systemd-networkd-wait-online.enable = pkgs.lib.mkForce false;
#  systemd.network = {
#    enable = true;
#
#    # Rename our main network interface to "phys0"
#    links."10-phys0" = {
#      matchConfig.PermanentMACAddress = "d8:5e:d3:a5:c7:37";
#      linkConfig.Name = "phys0";
#    };
#
#    # Create VLAN devices
#    netdevs."10-vlan-lan" = {
#      netdevConfig = {
#        Kind = "vlan";
#        Name = "vlan-lan";
#      };
#      vlanConfig.Id = 11;
#    };
#
#    netdevs."10-vlan-iot" = {
#      netdevConfig = {
#        Kind = "vlan";
#        Name = "vlan-iot";
#      };
#      vlanConfig.Id = 2;
#    };
#
#    netdevs."10-vlan-guest" = {
#      netdevConfig = {
#        Kind = "vlan";
#        Name = "vlan-guest";
#      };
#      vlanConfig.Id = 4;
#    };
#
#    netdevs."10-vlan-server" = {
#      netdevConfig = {
#        Kind = "vlan";
#        Name = "vlan-server";
#      };
#      vlanConfig.Id = 3;
#    };
#
#    netdevs."10-vlan-vpn" = {
#      netdevConfig = {
#        Kind = "vlan";
#        Name = "vlan-vpn";
#      };
#      vlanConfig.Id = 6;
#    };
#
#    # Create bridges
#    netdevs."10-bridge-lan".netdevConfig = {
#      Kind = "bridge";
#      Name = "br-lan";
#    };
#
#    netdevs."10-bridge-iot".netdevConfig = {
#      Kind = "bridge";
#      Name = "br-iot";
#    };
#    
#    netdevs."10-bridge-guest".netdevConfig = {
#      Kind = "bridge";
#      Name = "br-guest";
#    };
#    
#    netdevs."10-bridge-server".netdevConfig = {
#      Kind = "bridge";
#      Name = "br-server";
#    };
#    
#    netdevs."10-bridge-vpn".netdevConfig = {
#      Kind = "bridge";
#      Name = "br-vpn";
#    };
#
#    # Assign VLANs to physical ethernet device
#    networks."20-vlan-to-phys" = {
#      matchConfig.Name = "phys0";
#      networkConfig.VLAN = [ "vlan-lan" "vlan-iot" "vlan-guest" "vlan-server" "vlan-vpn" ];
#    };
#
#    # Put VLAN devices into bridges
#    networks."20-vlan-br-lan" = {
#      matchConfig.Name = "vlan-lan";
#      networkConfig.Bridge = "br-lan";
#    };
#
#    networks."20-vlan-br-iot" = {
#      matchConfig.Name = "vlan-iot";
#      networkConfig.Bridge = "br-iot";
#    };
#
#    networks."20-vlan-br-guest" = {
#      matchConfig.Name = "vlan-guest";
#      networkConfig.Bridge = "br-guest";
#    };
#
#    networks."20-vlan-br-server" = {
#      matchConfig.Name = "vlan-server";
#      networkConfig.Bridge = "br-server";
#    };
#
#    networks."20-vlan-br-vpn" = {
#      matchConfig.Name = "vlan-vpn";
#      networkConfig.Bridge = "br-vpn";
#    };
#
#    # Configure bridges for networks that we want the host to have access to
#    networks."30-br-lan" = {
#      matchConfig.Name = "br-lan";
#      addresses = [ { 
#        addressConfig.Address = "192.168.1.20/24";
#      } ];
#      networkConfig = {
#        Gateway = "192.168.1.1";
#        DNS = "192.168.1.1";
#      };
#    };
#
#    networks."30-br-server" = {
#      matchConfig.Name = "br-server";
#      addresses = [ { 
#        addressConfig.Address = "192.168.3.20/24";
#      } ];
#    };
#
#    # Configure other bridges without addresses to get them up
#    networks."30-br-guest".matchConfig.Name = "br-guest";
#    networks."30-br-iot".matchConfig.Name = "br-iot";
#    networks."30-br-vpn".matchConfig.Name = "br-vpn";
#
#    networks."40-vm-br-lan" = {
#      matchConfig.Name = "vm-lan-*";
#      networkConfig.Bridge = "br-lan";
#    };
#
#    networks."40.vm-br-server" = {
#      matchConfig.Name = "vm-srv-*";
#      networkConfig.Bridge = "br-server";
#    };
#
#    networks."40.vm-br-guest" = {
#      matchConfig.Name = "vm-gst-*";
#      networkConfig.Bridge = "br-guest";
#    };
#
#    networks."40.vm-br-iot" = {
#      matchConfig.Name = "vm-iot-*";
#      networkConfig.Bridge = "br-iot";
#    };
#
#    networks."40.vm-br-vpn" = {
#      matchConfig.Name = "vm-vpn-*";
#      networkConfig.Bridge = "br-vpn";
#    };
#
#  };

  # Extra user accounts (mainly for NFS)
  users.users.jan = {
    isNormalUser = true;
    uid = 1000;
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

