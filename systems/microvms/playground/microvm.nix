{ config, pkgs, ... }:
{
  #boot.kernelPackages = pkgs.lib.mkForce (pkgs.linuxPackages_latest.extend (_: _: {
  #  kernel = pkgs.linuxPackages_latest.callPackage ../custom-kernel.nix {};
  #}));
  microvm.hypervisor = "qemu";
  microvm.vcpu = 1;
  microvm.mem = 512;
  microvm.interfaces = [ {
    type = "tap";
    id = "vm-lan-playgrnd";
    mac = "ba:da:55:00:00:00";
  } ];
  microvm.shares = [ 
    {
      tag = "etc";
      socket = "etc.socket";
      source = "/vms/playground/etc";
      mountPoint = "/etc";
      proto = "virtiofs";
    } 
    {
      tag = "var";
      socket = "var.socket";
      source = "/vms/playground/var";
      mountPoint = "/var";
      proto = "virtiofs";
    } 
    {
      tag = "home";
      socket = "home.socket";
      source = "/vms/playground/home";
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
