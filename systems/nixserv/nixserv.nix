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
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ZFS related options
  boot.kernelParams = [ "nohibernate" ];
  boot.initrd.supportedFilesystems = [ "zfs" ];
  boot.supportedFilesystems = [ "zfs" "nfs" ];
  boot.zfs.extraPools = [ "diskpool" "ssdpool" ];

  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="sd[a-z]*[0-9]*|mmcblk[0-9]*p[0-9]*|nvme[0-9]*n[0-9]*p[0-9]*", ENV{ID_FS_TYPE}=="zfs_member", ATTR{../queue/scheduler}="none"
  ''; # zfs already has its own scheduler. without this my(@Artturin) computer froze for a second when i nix build something.  

  # Allow entering ZFS encryption key via SSH
  boot.initrd.kernelModules = [ "r8169" ];
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

  services.fwupd.enable = true;

  # Automatic ZFS maintenance
  services.zfs = {
    autoScrub.enable = true;
    trim.enable = true;
  };

  networking.hostName = "nixserv"; # Define your hostname.
  networking.domain = "matelab.de";
  networking.hostId = "744bb91a";
  networking.interfaces.enp3s0.useDHCP = true;
  networking.nameservers = [ "192.168.1.1" ];

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


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}

