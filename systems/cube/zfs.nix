{ config, pkgs, ... }:

{
  boot.supportedFilesystems = [ "zfs" ];
  networking.hostId = "ef578da1";
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.generationsDir.copyKernels = true;
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.copyKernels = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.zfsSupport = true;
  boot.loader.grub.useOSProber = true;
  boot.loader.grub.devices = [
    "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_1TB_S4EWNG0MC11352D"
  ];
}
