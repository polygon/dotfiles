{ config, pkgs, ... }:
{
  #boot.kernelPackages = pkgs.lib.mkForce (pkgs.linuxPackages_latest.extend (_: _: {
  #  kernel = pkgs.linuxPackages_latest.callPackage ../custom-kernel.nix {};
  #}));
  microvm.hypervisor = "qemu";
  microvm.vcpu = 1;
  microvm.mem = 4096;
  microvm.interfaces = [
    {
      type = "tap";
      id = "vm-lan-cloud";
      mac = "ba:da:55:03:00:00";
    } 
    {
      type = "tap";
      id = "vm-srv-cloud";
      mac = "ba:da:55:03:00:01";
    } 
  ];
  microvm.shares = [ 
    {
      tag = "etc";
      socket = "etc.socket";
      source = "/vms/cloud/etc";
      mountPoint = "/etc";
      proto = "virtiofs";
    } 
    {
      tag = "var";
      socket = "var.socket";
      source = "/vms/cloud/var";
      mountPoint = "/var";
      proto = "virtiofs";
    } 
    {
      tag = "home";
      socket = "home.socket";
      source = "/vms/cloud/home";
      mountPoint = "/home";
      proto = "virtiofs";
    } 
    {
      tag = "storage";
      socket = "storage.socket";
      source = "/vms/cloud/storage/hdd";
      mountPoint = "/storage/hdd";
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
