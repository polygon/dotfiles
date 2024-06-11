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

  # Enable VirtualBox
  modules.apps.virtualbox.enable = true;

  # Enable SyncThing
  modules.apps.syncthing.enable = true;

  # Audio production
  modules.apps.audioprod.enable = true;

  # == Host specific ==
  nixpkgs.overlays = [
    (self: super: {
      #sof-firmware = unstable.sof-firmware; 
      nix-direnv = unstable.nix-direnv;
    })
  ];
  hardware.opengl = {
    enable = true;
    # Steam
    driSupport32Bit = true;
  };

  # Use the systemd-boot EFI boot loader.
  boot.supportedFilesystems = [ "nfs" "ntfs" ];
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  boot.kernelModules = [ "acpi_call" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];

  services.fwupd.enable = true;

  services.zfs = {
    autoScrub.enable = true;
    trim.enable = true;
  };

  networking.hostName = "cube"; # Define your hostname.

  networking.firewall = {
    enable = true;
    allowPing = true;
  };

  systemd.network.networks."ethernet".extraConfig = ''
    [Match]
    Type = ether

    [Network]
    DHCP = yes
  '';

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  #  services.xserver.videoDrivers = [ "nouveau" ];
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
  #  services.xserver.synaptics.enable = true;

  services.resolved.enable = true;

  # Enable the GNOME 3 Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.displayManager.defaultSession = "plasmax11";
  services.desktopManager.plasma6.enable = true;

  programs.dconf.enable = true;

  # Configure keymap in X11
  services.xserver.xkb.layout = "de";
  # services.xserver.xkbOptions = "eurosign:e";

  #  fonts.fontconfig = {
  #    hinting.style = "hintnone";
  #    hinting.autohint = false;
  #    hinting.enable = false;
  #    subpixel.rgba = "vrgb";
  #    subpixel.lcdfilter = "none";
  #  };

  fonts.fontconfig.localConf = ''
    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
    <fontconfig>
      <match target="font">
        <edit name="hintstyle" mode="assign"><const>hintslight</const></edit>
        <edit name="autohint" mode="assign"><bool>true</bool></edit>
        <edit name="antialias" mode="assign"><bool>true</bool></edit>
        <edit name="rgba" mode="assign"><const>rgb</const></edit>
        <edit name="lcdfilter" mode="assign"><const>lcddefault</const></edit>
      </match>
    </fontconfig>
  '';

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = false;
  hardware.pulseaudio.enable = false;

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
#        matches = [{ "device.name" = "~bluez_card.*"; }];
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
#    
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
#          name = "libpipewire-module-portal";
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

  # Define a user account. Don't forget to set a password with ‘passwd’.

  users.users.dude = {
    uid = 1001;
    isNormalUser = true;
    shell = pkgs.zsh;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    xboxdrv
  ];

  environment.variables = {
    #GDK_SCALE = "2";
    #GDK_DPI_SCALE = "0.5";
    #_JAVA_OPTIONS = "-Dsun.java2d.uiScale=2";
    #VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/intel_icd.x86_64.json";
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

  # Serve Nix Store of this machine
  nix.sshServe = {
    enable = true;
    keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDMfpLyBuT0Yu8R2MiYBxAfAKddVe1URRYafw4SjdBnx nixget@matelab"
    ];
  };

  nix.extraOptions = ''
    secret-key-files = /root/nix-cache/nix-cache-key.sec
  '';

  # Space Mouse
  hardware.spacenavd.enable = true;

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
  system.stateVersion = "22.11"; # Did you read the comment?

}

