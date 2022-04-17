# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, unstable, ... }:
{
  # == Module Configuration ==

  # General settings for all clients/workstations
  modules.systems.client.enable = true;

  # Enable Wireguard tunnels
  # modules.wireguard.mullvad.enable = true;

  # == Host specific ==
  nixpkgs.overlays = [ 
    (self: super: { 
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
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";
  boot.kernelPackages = pkgs.linuxPackages_latest;

  services.fwupd.enable = true;

  services.zfs = {
    autoScrub.enable = true;
    trim.enable = true;
  };

  networking.hostName = "travelnix"; # Define your hostname.
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
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.windowManager.awesome.enable = true;
  

  # Configure keymap in X11
  services.xserver.layout = "de";
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

    media-session.config.bluez-monitor.rules = [
      {
        matches = [ { "device.name" = "~bluez_card.*"; } ];
        actions = {
          "update-props" = {
            "bluez5.reconnect-profiles" = [ "hfp_hf" "hsp_hs" "a2dp_sink" ];
            "bluez5.msbc-support" = true;
            "bluez5.sbc-xq-support" = true;
          };
        };
      }
      {
        matches = [
          { "node.name" = "~bluez_input.*"; }
          { "node.name" = "~bluez_output.*"; }
        ];
        actions = {
          "node.pause-on-idle" = false;
        };
      }
    ];

    config.pipewire = {
      "context.properties" = {
        "link.max-buffers" = 16;
        "log.level" = 2;
        "default.clock.rate" = 48000;
        "default.clock.quantum" = 256;
        "default.clock.min-quantum" = 256;
        "default.clock.max-quantum" = 1024;
        "core.daemon" = true;
        "core.name" = "pipewire-0";
      };
      
      "context.spa-libs" = {
        "audio.convert.*" = "audioconvert/libspa-audioconvert";
        "api.alsa.*" = "alsa/libspa-alsa";
        "api.v4l2.*" = "v4l2/libspa-v4l2";
        "api.libcamera.*" = "libcamera/libspa-libcamera";
        "api.bluez5.*" = "bluez5/libspa-bluez5";
        "api.vulkan.*" = "vulkan/libspa-vulkan";
        "api.jack.*" = "jack/libspa-jack";
        "support.*" = "support/libspa-support";
      };

      "context.modules" = [
        {
          name = "libpipewire-module-rtkit";
          args = {
            "nice.level" = -15;
            "rt.prio" = 88;
            "rt.time.soft" = 200000;
            "rt.time.hard" = 200000;            
          };
          flags = [ "ifexists" "nofail" ];
        }
        { name = "libpipewire-module-protocol-native"; }
        { name = "libpipewire-module-profiler"; }
        { name = "libpipewire-module-metadata"; }
        { name = "libpipewire-module-spa-device-factory"; }
        { name = "libpipewire-module-spa-node-factory"; }
        { name = "libpipewire-module-client-node"; }
        { name = "libpipewire-module-client-device"; }
        { 
				  name = "libpipewire-module-portal";
          flags = [ "ifexists" "nofail" ];
        }
        { name = "libpipewire-module-access"; args = { }; }
        { name = "libpipewire-module-adapter"; }
        { name = "libpipewire-module-link-factory"; }
        { name = "libpipewire-module-session-manager"; }
        {
          name = "libpipewire-module-protocol-pulse";
          args = {
            "server.address" = [
              "unit.native"
              "tcp:4713"
            ];
          };
        }
      ];
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    direnv
    (nix-direnv.override { enableFlakes = true; })
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

