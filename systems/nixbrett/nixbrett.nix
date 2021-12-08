# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, unstable, ... }:
{
  # == Module Configuration ==

  # General settings for all clients/workstations
  modules.systems.client.enable = true;

  # Enable Wireguard tunnels
  modules.wireguard.mullvad.enable = true;
  modules.wireguard.wacken.enable = true;

  # == Host specific ==
  nixpkgs.overlays = [ 
    (self: super: { 
      sof-firmware = unstable.sof-firmware; 
      nix-direnv = unstable.nix-direnv;
    } ) 
  ];
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
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.supportedFilesystems = [ "zfs" ];
  boot.supportedFilesystems = [ "zfs" "nfs" ];
  boot.kernelPackages = pkgs.linuxPackages;
  boot.kernelModules = [ "acpi_call" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];

  services.zfs = {
    autoScrub.enable = true;
    trim.enable = true;
  };

  networking.hostName = "nixbrett"; # Define your hostname.
  networking.wireless.iwd.enable = true;

  networking.hostId = "3ba26467";

  networking.firewall = {
    enable = true;
    allowPing = true;
    allowedTCPPorts = [
      20000
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

  services.printing.enable = true;
  services.avahi.enable = true;
  # Important to resolve .local domains of printers, otherwise you get an error
  # like  "Impossible to connect to XXX.local: Name or service not known"
  services.avahi.nssmdns = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.

  # Enable the X11 windowing system.
  services.xserver.enable = true;
#  services.xserver.synaptics.enable = true;

  services.resolved.enable = true;

  # Enable the GNOME 3 Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.windowManager.awesome.enable = true;
  

  # Configure keymap in X11
  services.xserver.layout = "de";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    package = unstable.pulseaudioFull;
    extraModules = [ unstable.pulseaudio-modules-bt ];
  };
  hardware.bluetooth.enable = true;
  hardware.bluetooth.settings = {
    General = {
      Enabe = "Source,Sink,Media,Socket";
    };
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;
  services.xserver.libinput.touchpad = {
    tapping = true;
    clickMethod = "clickfinger";
    accelSpeed = "0.2";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.

  users.users.dude = {
    uid = 1001;
    isNormalUser = true;
    shell = pkgs.zsh;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    sof-firmware
    direnv
    (nix-direnv.override { enableFlakes = true; })
    xboxdrv
  ];

  environment.variables = {
    GDK_SCALE = "2";
    GDK_DPI_SCALE = "0.5";
    _JAVA_OPTIONS = "-Dsun.java2d.uiScale=2";
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

  # udev
  # Assign plugdev for radi0 users
  services.udev.packages = [ unstable.hackrf ];

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
  system.stateVersion = "20.09"; # Did you read the comment?

}

