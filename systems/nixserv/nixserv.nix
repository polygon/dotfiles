# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, unstable, ... }:
{
  # == Module Configuration ==

  time.timeZone = "Europe/Berlin";

  hardware.cpu.intel.updateMicrocode = true;
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  boot.initrd.supportedFilesystems = [ "zfs" ];
  boot.supportedFilesystems = [ "zfs" "nfs" ];

  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="sd[a-z]*[0-9]*|mmcblk[0-9]*p[0-9]*|nvme[0-9]*n[0-9]*p[0-9]*", ENV{ID_FS_TYPE}=="zfs_member", ATTR{../queue/scheduler}="none"
  ''; # zfs already has its own scheduler. without this my(@Artturin) computer froze for a second when i nix build something.  

  services.fwupd.enable = true;

  services.zfs = {
    autoScrub.enable = true;
    trim.enable = true;
  };

  networking.hostName = "nixserv"; # Define your hostname.
  networking.hostId = "744bb91a";
  networking.useDHCP = false;
  networking.interfaces.enp3s0.useDHCP = true;
  services.openssh.enable = true;


  console = {
    font = "Lat2-Terminus16";
    keyMap = "de";
  };

 # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jan = {
    isNormalUser = true;
    uid = 1000;
  };

  users.users.dude = {
    isNormalUser = true;
    uid = 1001;
  };

  users.users.admin = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    uid = 10000;
    shell = pkgs.zsh;
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

  environment.systemPackages = with pkgs; [
    vim
    wget
    tmux
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}

