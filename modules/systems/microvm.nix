{ config, lib, pkgs, ... }:

with lib;

# Config that should be the same on all server machines

let
  cfg = config.modules.systems.microvm;
in
{
  options.modules.systems.microvm.enable = mkEnableOption "MicroVM default";

  config = mkIf cfg.enable {
    modules.systems.base.enable = true;
    
    nix.trustedUsers = [ "admin" ];

    security.sudo.extraRules = [
      {
        users = [ "admin" ];
        commands = [ { command = "ALL"; options = [ "SETENV" "NOPASSWD" ]; } ];
      }
    ];

    networking.networkmanager.enable = false;    

    users.users.admin = {
      uid = 10000;
      isNormalUser = true;
      extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICGEKrCGXyHqD0jdTYVHnnScL9mhDU2PR9VyH7fu528J"
      ];
    };

    programs.tmux = {
      enable = true;
      baseIndex = 1;
      clock24 = true;
      historyLimit = 10000;
      terminal = "tmux-256color";
      extraConfig = ''
        unbind C-b
        set-option -g prefix C-a
        bind-key C-a last-window
        set-option -g set-titles on
        set-option -g set-titles-string '#H:#S.#I.#P #W #T'
        setw -g monitor-activity on
        set-option -g status-justify left
        set-option -g status-bg yellow
        set-option -g status-fg black
      '';
	  };

    programs.git = {
      enable = true;
      config = {
        user.name = "polygon";
        user.email = "polygon@wh2.tu-dresden.de";
        init.defaultBranch = "main";
      };
    };

    programs.neovim = {
      enable = true;
      configure.customRC = ''
        set noexpandtab
        set shiftwidth=2
        set tabstop=2
      
        set cindent
        set smartindent
        set autoindent
        set foldmethod=syntax
        nmap <F2> zA
        nmap <F3> zR
        nmap <F4> zM
        syntax enable
      '';
      vimAlias = true;
    };
  }; 
}
