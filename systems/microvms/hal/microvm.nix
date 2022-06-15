{ config, pkgs, ... }:
{
  #boot.kernelPackages = pkgs.lib.mkForce (pkgs.linuxPackages_latest.extend (_: _: {
  #  kernel = pkgs.linuxPackages_latest.callPackage ../custom-kernel.nix {};
  #}));
  microvm.hypervisor = "qemu";
  microvm.vcpu = 1;
  microvm.mem = 2048;
  microvm.interfaces = [
    {
      type = "tap";
      id = "vm-lan-hal";
      mac = "ba:da:55:02:00:00";
    } 
    {
      type = "tap";
      id = "vm-srv-hal";
      mac = "ba:da:55:02:00:01";
    } 
    {
      type = "tap";
      id = "vm-iot-hal";
      mac = "ba:da:55:02:00:02";
    }
  ];
  microvm.shares = [ 
    {
      tag = "etc";
      socket = "etc.socket";
      source = "/vms/hal/etc";
      mountPoint = "/etc";
      proto = "virtiofs";
    } 
    {
      tag = "var";
      socket = "var.socket";
      source = "/vms/hal/var";
      mountPoint = "/var";
      proto = "virtiofs";
    } 
    {
      tag = "home";
      socket = "home.socket";
      source = "/vms/hal/home";
      mountPoint = "/home";
      proto = "virtiofs";
    } 
    {
      tag = "ro-store";
      source = "/nix/store";
      mountPoint = "/nix/.ro-store";
      socket = "ro-store.socket";
      proto = "virtiofs";
    }
  ];
  microvm.writableStoreOverlay = null;
}
