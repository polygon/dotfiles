{ config, pkgs, ... }:
{
  #boot.kernelPackages = pkgs.lib.mkForce (pkgs.linuxPackages_latest.extend (_: _: {
  #  kernel = pkgs.linuxPackages_latest.callPackage ../custom-kernel.nix {};
  #}));
  microvm.hypervisor = "qemu";
  microvm.vcpu = 4;
  microvm.mem = 2048;
  microvm.interfaces = [
    {
      type = "tap";
      id = "vm-lan-paprless";
      mac = "ba:da:55:01:00:00";
    } 
    {
      type = "tap";
      id = "vm-srv-paprless";
      mac = "ba:da:55:01:00:01";
    } 
  ];
  microvm.shares = [ 
    {
      tag = "etc";
      socket = "etc.socket";
      source = "/vms/paperless/etc";
      mountPoint = "/etc";
      proto = "virtiofs";
    } 
    {
      tag = "var";
      socket = "var.socket";
      source = "/vms/paperless/var";
      mountPoint = "/var";
      proto = "virtiofs";
    } 
    {
      tag = "home";
      socket = "home.socket";
      source = "/vms/paperless/home";
      mountPoint = "/home";
      proto = "virtiofs";
    } 
    {
      tag = "data";
      socket = "data.socket";
      source = "/vms/paperless/data";
      mountPoint = "/var/lib/paperless";
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
