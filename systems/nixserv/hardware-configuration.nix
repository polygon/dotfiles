# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "ssdpool/nixos/root";
      fsType = "zfs";
    };

  fileSystems."/var" =
    { device = "ssdpool/nixos/var";
      fsType = "zfs";
    };
    
  fileSystems."/nix" =
    { device = "ssdpool/nixos/nix";
      fsType = "zfs";
    };

  fileSystems."/var/lib" =
    { device = "ssdpool/nixos/var/lib";
      fsType = "zfs";
    };

  fileSystems."/var/log" =
    { device = "ssdpool/nixos/var/log";
      fsType = "zfs";
    };

  fileSystems."/etc" =
    { device = "ssdpool/nixos/etc";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/CB47-BE69";
      fsType = "vfat";
    };

  fileSystems."/home/jan" =
    { device = "ssdpool/home/jan";
      fsType = "zfs";
    };

  fileSystems."/home/dude" =
    { device = "ssdpool/home/dude";
      fsType = "zfs";
    };

  fileSystems."/home/admin" =
    { device = "ssdpool/home/admin";
      fsType = "zfs";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/940a48b1-4e97-40da-988b-b5b9cc742498"; }
    ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
