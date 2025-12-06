# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, unstable, ... }: {
  # == Module Configuration ==

  # General settings for all clients/workstations
  modules.systems.client.enable = true;

  # Enable Wireguard tunnels
  #modules.wireguard.mullvad.enable = true;
  #modules.wireguard.wacken.enable = true;

  # Enable SyncThing
  modules.apps.syncthing.enable = true;

  # Audio production
  modules.apps.audioprod.enable = true;

  # Android Debug Bridge
  #modules.apps.adb.enable = true;

  # Yabridgemgr
  #modules.audio-nix.yabridgemgr = {
  #  enable = true;
  #  user = "jan";
  #};

  # == Host specific ==
  #nixpkgs.overlays = [
  #  (self: super: {
  #    sof-firmware = unstable.sof-firmware;
  #    nix-direnv = unstable.nix-direnv;
  #  })
  #];
  #nixpkgs.config.packageOverrides = pkgs: {
  #  vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  #};
  #hardware.graphics = {
  #  enable = true;
  #  extraPackages = with pkgs; [
  #    intel-media-driver
  #    vaapiIntel
  #    vaapiVdpau
  #    libvdpau-va-gl
  #  ];
  #  # Steam
  #  enable32Bit = true;
  #};
  hardware.cpu.intel.updateMicrocode = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.zfs.removeLinuxDRM = true;
  boot.kernelPackages = pkgs.linuxPackages_6_17;

  services.fwupd.enable = true;

  #services.mullvad-vpn.enable = true;

  services.zfs = {
    autoScrub.enable = true;
    trim.enable = true;
  };

  networking.hostName = "nixbrett"; # Define your hostname.
  networking.wireless.iwd.enable = true;

  networking.hostId = "51192e49";

  networking.firewall = {
    enable = true;
    allowPing = true;
    allowedTCPPorts = [ 20000 ];
  };

  programs.ausweisapp = {
    enable = true;
    openFirewall = true;
  };  

#  networking.wireless.networks."Camp2023".auth = ''
#    key_mgmt=WPA-EAP
#    eap=TTLS
#    identity="camp"
#    password="camp"
#    ca_cert="${
#      builtins.fetchurl {
#        url = "https://letsencrypt.org/certs/isrgrootx1.pem";
#        sha256 = "sha256:1la36n2f31j9s03v847ig6ny9lr875q3g7smnq33dcsmf2i5gd92";
#      }
#    }"
#    altsubject_match="DNS:radius.c3noc.net"
#    phase2="auth=PAP"
#  '';

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

 # systemd.network.networks."wacken".extraConfig = ''
 #   [Match]
 #   Name = wacken
#
#    [Network]
#    DNS = 192.168.1.1
#    Domains = ~matelab.de
#  '';

  services.blueman.enable = true;

  services.printing.enable = true;
  services.avahi.enable = true;
  # Important to resolve .local domains of printers, otherwise you get an error
  # like  "Impossible to connect to XXX.local: Name or service not known"
  services.avahi.nssmdns4 = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "modesetting" ];
  #  services.xserver.synaptics.enable = true;

  services.resolved.enable = true;

  # Enable the GNOME 3 Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.displayManager.defaultSession = "plasmax11";
  services.desktopManager.plasma6.enable = true;

  programs.dconf.enable = true;

  programs.steam.enable = true;

  #services.thermald.enable = true;

  # Configure keymap in X11
  services.xserver.xkb.layout = "de";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  services.pulseaudio.enable = false;
  hardware.enableAllFirmware = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.settings = {
    General = { Enabe = "Source,Sink,Media,Socket"; };
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

    #    media-session.config.bluez-monitor.rules = [
    #      {
    #        matches = [ { "device.name" = "~bluez_card.*"; } ];
    #        actions = {
    #          "update-props" = {
    #            "bluez5.reconnect-profiles" = [ "hfp_hf" "hsp_hs" "a2dp_sink" ];
    #            "bluez5.msbc-support" = true;
    #            "bluez5.sbc-xq-support" = true;
    #          };
    #        };
    #      }
    #      {
    #        matches = [
    #          { "node.name" = "~bluez_input.*"; }
    #          { "node.name" = "~bluez_output.*"; }
    #        ];
    #        actions = {
    #          "node.pause-on-idle" = false;
    #        };
    #      }
    #    ];

    #    config.pipewire = {
    #      "context.properties" = {
    #        "link.max-buffers" = 16;
    #        "log.level" = 2;
    #        "default.clock.rate" = 48000;
    #        "default.clock.quantum" = 256;
    #        "default.clock.min-quantum" = 256;
    #        "default.clock.max-quantum" = 1024;
    #        "core.daemon" = true;
    #        "core.name" = "pipewire-0";
    #      };
    #      
    #      "context.spa-libs" = {
    #        "audio.convert.*" = "audioconvert/libspa-audioconvert";
    #        "api.alsa.*" = "alsa/libspa-alsa";
    #        "api.v4l2.*" = "v4l2/libspa-v4l2";
    #        "api.libcamera.*" = "libcamera/libspa-libcamera";
    #        "api.bluez5.*" = "bluez5/libspa-bluez5";
    #        "api.vulkan.*" = "vulkan/libspa-vulkan";
    #        "api.jack.*" = "jack/libspa-jack";
    #        "support.*" = "support/libspa-support";
    #      };
    #
    #      "context.modules" = [
    #        {
    #          name = "libpipewire-module-rtkit";
    #          args = {
    #            "nice.level" = -15;
    #            "rt.prio" = 88;
    #            "rt.time.soft" = 200000;
    #            "rt.time.hard" = 200000;            
    #          };
    #          flags = [ "ifexists" "nofail" ];
    #        }
    #        { name = "libpipewire-module-protocol-native"; }
    #        { name = "libpipewire-module-profiler"; }
    #        { name = "libpipewire-module-metadata"; }
    #        { name = "libpipewire-module-spa-device-factory"; }
    #        { name = "libpipewire-module-spa-node-factory"; }
    #        { name = "libpipewire-module-client-node"; }
    #        { name = "libpipewire-module-client-device"; }
    #        { 
    #				  name = "libpipewire-module-portal";
    #          flags = [ "ifexists" "nofail" ];
    #        }
    #        { name = "libpipewire-module-access"; args = { }; }
    #        { name = "libpipewire-module-adapter"; }
    #        { name = "libpipewire-module-link-factory"; }
    #        { name = "libpipewire-module-session-manager"; }
    #        {
    #          name = "libpipewire-module-protocol-pulse";
    #          args = {
    #            "server.address" = [
    #              "unit.native"
    #              "tcp:4713"
    #            ];
    #          };
    #        }
    #      ];
    #    };
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;
  services.libinput.touchpad = {
    tapping = true;
    clickMethod = "clickfinger";
    accelSpeed = "0.2";
  };

  #services.picom.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.

  users.users.dude = {
    uid = 1001;
    isNormalUser = true;
    shell = pkgs.zsh;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [ sof-firmware ];

  environment.variables = {
    #GDK_SCALE = "2";
    #GDK_DPI_SCALE = "0.5";
    #_JAVA_OPTIONS = "-Dsun.java2d.uiScale=2";
    #VK_ICD_FILENAMES =
    #  "/run/opengl-driver/share/vulkan/icd.d/intel_icd.x86_64.json";
    #vblank_mode = "0";
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
  system.stateVersion = "25.05"; # Did you read the comment?

}

