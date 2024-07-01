# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, unstable, ... }:
{
  # == Module Configuration ==

  # General settings for all clients/workstations
  modules.systems.server.enable = true;

  # Enable Wireguard tunnels
  # modules.wireguard.mullvad.enable = true;

  # == Host specific ==
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
    ];
    # Steam
    driSupport32Bit = true;
  };
  hardware.cpu.intel.updateMicrocode = true;
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";
  boot.kernelPackages = pkgs.linuxPackages_latest;

  services.fwupd.enable = true;

  services.zfs = {
    autoScrub.enable = true;
    trim.enable = true;
  };

  networking.hostName = "midimaxe"; # Define your hostname.
  networking.wireless.iwd.enable = true;

  networking.firewall = {
    enable = true;
    allowPing = true;
    allowedTCPPorts = [
    ];
  };
  
  systemd.network.networks."ethernet".extraConfig = ''
    [Match]
    Type = ether

    [Network]
    DHCP = yes
  '';

  systemd.network.networks."wifi".extraConfig = ''
    [Match]
    Type = wlan

    [Network]
    DHCP = yes

    [DHCP]
    UseDomains = true
  '';

  services.blueman.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.

  # Enable the X11 windowing system.
  services.xserver.enable = true;
#  services.xserver.synaptics.enable = true;

  services.resolved.enable = true;

  # Enable the GNOME 3 Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.windowManager.awesome.enable = true;
  

  # Configure keymap in X11
  services.xserver.xkb.layout = "de";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = false;
  hardware.pulseaudio.enable = false;
##  hardware.pulseaudio = {
##    enable = true;
##    package = unstable.pulseaudioFull;
##    extraModules = [ unstable.pulseaudio-modules-bt ];
##  };

  hardware.bluetooth.enable = true;
  hardware.bluetooth.settings = {
    General = {
      Enabe = "Source,Sink,Media,Socket";
    };
  };

  # Pipewire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  ];

  environment.variables = {
    VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/intel_icd.x86_64.json";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # ACPID
  services.acpid = {
    enable = true;
    logEvents = true;
  };

  users.users.midimaxe = {
    uid = 1002;
    isNormalUser = true;
    shell = pkgs.zsh;
  };


  #containers.postgres = {
  #  config = { config, pkgs, ... }: {
  #    services.postgresql = {
  #      enable = true;
  #      package = unstable.postgresql_14;
  #      extraPlugins = with unstable.postgresql_14.pkgs; [ age ];
  #      enableTCPIP = true;
  #    };
  #  };
  #};

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}

