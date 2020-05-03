# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let

  vertical = pkgs.writeScriptBin "f" ''
xrandr -o right
xinput set-prop "GXTP7386:00 27C6:0113" --type=float "Coordinate Transformation Matrix" -1 0 1 0 -1 1 0 0 1
'';

  portrait = pkgs.writeScriptBin "p" ''
#portrait (left)
xrandr -o left 
xinput set-prop "GXTP7386:00 27C6:0113" --type=float "Coordinate Transformation Matrix" 0 -1 1 1 0 0 0 0 1
'';

  landscape = pkgs.writeScriptBin "lscape" ''
#landscape (normal)
xrandr -o normal
xinput set-prop "GXTP7386:00 27C6:0113" --type=float "Coordinate Transformation Matrix" 0 0 0 0 0 0 0 0 0
'';

in {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices.sroot = {
    device = "/dev/nvme0n1p2";
    preLVM = true;
  };

  security.sudo.wheelNeedsPassword = false;
  
  networking.hostName = "micro.px.io"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.nameservers = ["8.8.8.8" "4.4.4.4" "1.1.1.1" "1.0.0.1"];
  networking.hosts = import ./secrets/hosts.nix;

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "fr_FR.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    wget vim portrait landscape vertical
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = { enable = true; enableSSHSupport = true; };
  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  networking.firewall.enable = false;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "eurosign:e";

  # Enable touchpad support.
  services.xserver.libinput.enable = true;

  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = false;
  services.xserver.desktopManager.gnome3.enable = true;

  krb5 = {
    enable = true;
    realms = {
      "KRB.LAN" = {
        kdc = "127.0.0.1";
        admin_server = "127.0.0.1";
        default_domain = "KRB.LAN";
      };
    };
    libdefaults.default_realm = "KRB.LAN";
    libdefaults.dns_lookup_kdc   = "no";
    libdefaults.dns_lookup_realm = "no";
    # The following krb5.conf variables are only for MIT Kerberos.
	  libdefaults.krb4_config = "/etc/krb.conf";
	  libdefaults.krb4_realms = "/etc/krb.realms";
	  libdefaults.kdc_timesync = "1";
	  libdefaults.ccache_type = "4";
	  libdefaults.forwardable = true;
	  libdefaults.proxiable = true;
    domain_realm = {
      ".krb.lan" = "KRB.LAN";
    };
  };

  virtualisation = {
    docker = {
      enable = true;
    };
    virtualbox.host.enable = true;
    virtualbox.host.enableExtensionPack = true;
    anbox.enable = true;
  };
  systemd.services.docker.path = [ pkgs.kmod pkgs.git ];
  
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.alex = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ]; # Enable ‘sudo’ for the user.
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.09"; # Did you read the comment?

}
