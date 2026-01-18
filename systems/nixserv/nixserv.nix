# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, unstable, ... }:
{
  # == Module Configuration ==

  modules.systems.server.enable = true;

  hardware.cpu.intel.updateMicrocode = true;
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./nginx.nix
      ./acme.nix
      ./postgres.nix
      ./influxdb.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ZFS related options
  boot.kernelPackages = pkgs.linuxPackages_6_18;
  boot.kernelParams = [ "nohibernate" ];
  boot.initrd.supportedFilesystems = [ "zfs" ];
  boot.supportedFilesystems = [ "zfs" "nfs" ];
  boot.zfs.extraPools = [ "diskpool" "ssdpool" ];
  boot.zfs.package = pkgs.zfs_2_4;

  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="sd[a-z]*[0-9]*|mmcblk[0-9]*p[0-9]*|nvme[0-9]*n[0-9]*p[0-9]*", ENV{ID_FS_TYPE}=="zfs_member", ATTR{../queue/scheduler}="none"
  ''; # zfs already has its own scheduler. without this my(@Artturin) computer froze for a second when i nix build something.  

  # Allow entering ZFS encryption key via SSH
  boot.initrd.kernelModules = [ "r8169" "8021q" ];
  boot.initrd.network = {
    enable = true;
    ssh = {
      enable = true;
      port = 22022;
      hostKeys = [ /etc/ssh/initrd/ssh_host_ed25519_key ];
      authorizedKeys = [ 
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICGEKrCGXyHqD0jdTYVHnnScL9mhDU2PR9VyH7fu528J"
      ];
    };
    postCommands = ''
      echo "Bring up network on VLAN 11"
      ip link set phys0 up
      ip link add link phys0 name vlan-lan-boot type vlan id 11
      ip link set vlan-lan-boot up
      ip a a 192.168.1.20/24 dev vlan-lan-boot
      ip r a 0/0 via 192.168.1.1

      cat <<EOF > /root/.profile
      if pgrep -x "zfs" > /dev/null
      then
        zfs load-key -a
        killall zfs
      else
        echo "zfs not running -- maybe the pool is taking some time to load for some unforseen reason."
      fi
      EOF
    '';

  };
  
  boot.initrd.postMountCommands = ''
    echo "Shutting down network"
    ip a flush vlan-lan-boot
    ip link set vlan-lan-boot down
    ip link del vlan-lan-boot
    ip a flush phys0
    ip link set phys0 down
  '';

  services.fwupd.enable = true;

  # Automatic ZFS maintenance
  services.zfs = {
    autoScrub.enable = true;
    trim.enable = true;
  };

  networking = {
    hostName = "nixserv";
    domain = "matelab.de";
    hostId = "744bb91a";
    dhcpcd.enable = false;
    useNetworkd = true;
  };

  systemd.services.systemd-networkd-wait-online.enable = pkgs.lib.mkForce false;
  systemd.network = {
    enable = true;

    # Rename our main network interface to "phys0"
    links."10-phys0" = {
      matchConfig.PermanentMACAddress = "d8:5e:d3:a5:c7:37";
      linkConfig.Name = "phys0";
    };

    # Create VLAN devices
    netdevs."10-vlan-lan" = {
      netdevConfig = {
        Kind = "vlan";
        Name = "vlan-lan";
      };
      vlanConfig.Id = 11;
    };

    netdevs."10-vlan-iot" = {
      netdevConfig = {
        Kind = "vlan";
        Name = "vlan-iot";
      };
      vlanConfig.Id = 2;
    };

    netdevs."10-vlan-guest" = {
      netdevConfig = {
        Kind = "vlan";
        Name = "vlan-guest";
      };
      vlanConfig.Id = 4;
    };

    netdevs."10-vlan-server" = {
      netdevConfig = {
        Kind = "vlan";
        Name = "vlan-server";
      };
      vlanConfig.Id = 3;
    };

    netdevs."10-vlan-vpn" = {
      netdevConfig = {
        Kind = "vlan";
        Name = "vlan-vpn";
      };
      vlanConfig.Id = 6;
    };

    # Create bridges
    netdevs."10-bridge-lan".netdevConfig = {
      Kind = "bridge";
      Name = "br-lan";
    };

    netdevs."10-bridge-iot".netdevConfig = {
      Kind = "bridge";
      Name = "br-iot";
    };
    
    netdevs."10-bridge-guest".netdevConfig = {
      Kind = "bridge";
      Name = "br-guest";
    };
    
    netdevs."10-bridge-server".netdevConfig = {
      Kind = "bridge";
      Name = "br-server";
    };
    
    netdevs."10-bridge-vpn".netdevConfig = {
      Kind = "bridge";
      Name = "br-vpn";
    };

    # Assign VLANs to physical ethernet device
    networks."20-vlan-to-phys" = {
      matchConfig.Name = "phys0";
      networkConfig.VLAN = [ "vlan-lan" "vlan-iot" "vlan-guest" "vlan-server" "vlan-vpn" ];
    };

    # Put VLAN devices into bridges
    networks."20-vlan-br-lan" = {
      matchConfig.Name = "vlan-lan";
      networkConfig.Bridge = "br-lan";
    };

    networks."20-vlan-br-iot" = {
      matchConfig.Name = "vlan-iot";
      networkConfig.Bridge = "br-iot";
    };

    networks."20-vlan-br-guest" = {
      matchConfig.Name = "vlan-guest";
      networkConfig.Bridge = "br-guest";
    };

    networks."20-vlan-br-server" = {
      matchConfig.Name = "vlan-server";
      networkConfig.Bridge = "br-server";
    };

    networks."20-vlan-br-vpn" = {
      matchConfig.Name = "vlan-vpn";
      networkConfig.Bridge = "br-vpn";
    };

    # Configure bridges for networks that we want the host to have access to
    networks."30-br-lan" = {
      matchConfig.Name = "br-lan";
      addresses = [ { 
        Address = "192.168.1.20/24";
      } ];
      networkConfig = {
        Gateway = "192.168.1.1";
        DNS = "192.168.1.1";
      };
    };

    networks."30-br-server" = {
      matchConfig.Name = "br-server";
      addresses = [ { 
        Address = "192.168.3.20/24";
      } ];
    };

    # Configure other bridges without addresses to get them up
    networks."30-br-guest".matchConfig.Name = "br-guest";
    networks."30-br-iot".matchConfig.Name = "br-iot";
    networks."30-br-vpn".matchConfig.Name = "br-vpn";

    networks."40-vm-br-lan" = {
      matchConfig.Name = "vm-lan-*";
      networkConfig.Bridge = "br-lan";
    };

    networks."40.vm-br-server" = {
      matchConfig.Name = "vm-srv-*";
      networkConfig.Bridge = "br-server";
    };

    networks."40.vm-br-guest" = {
      matchConfig.Name = "vm-gst-*";
      networkConfig.Bridge = "br-guest";
    };

    networks."40.vm-br-iot" = {
      matchConfig.Name = "vm-iot-*";
      networkConfig.Bridge = "br-iot";
    };

    networks."40.vm-br-vpn" = {
      matchConfig.Name = "vm-vpn-*";
      networkConfig.Bridge = "br-vpn";
    };

  };

  # Extra user accounts (mainly for NFS)
  users.users.jan = {
    isNormalUser = true;
    uid = 1000;
  };

  users.users.dude = {
    isNormalUser = true;
    uid = 1001;
  };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.

  services.resolved.enable = true;

  # ACPID
  services.acpid = {
    enable = true;
    logEvents = true;
  };

  # NFS
  services.nfs.server.enable = true;
  networking.firewall.allowedTCPPorts = [ 2049 ];

  environment.systemPackages = with pkgs; [
  ];

  security.dhparams.stateful = true;

  # MicroVMs to autostart
  microvm.autostart = [
    "paperless"
    "hal"
    "cloud"
  ];


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}

