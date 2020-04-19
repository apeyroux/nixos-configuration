# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  portrait = pkgs.writeScriptBin "p" ''
#portrait (left)

xrandr -o left 
xinput set-prop "xwayland-touch:16" --type=float "Coordinate Transformation Matrix" 0 -1 1 1 0 0 0 0 1 
'';

  landscape = pkgs.writeScriptBin "lscape" ''
#landscape (normal)

xrandr -o normal
xinput set-prop "xwayland-touch:16" --type=float "Coordinate Transformation Matrix" 0 0 0 0 0 0 0 0 0
'';

  
in {
  imports = [
    #Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  networking.hostName = "micro.px.io"; # Define your hostname.
  networking.networkmanager.enable = true;
  networking.nameservers = ["8.8.8.8" "4.4.4.4" "1.1.1.1" "1.0.0.1"];
  networking.hosts = import ./secrets/hosts.nix;
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  # networking.useDHCP = false;
  # networking.interfaces.wlp2s0.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    landscape
    portrait
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryFlavor = "gnome3";
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "eurosign:e";

  # Enable touchpad support.
  services.xserver.libinput.enable = true;

  # Enable the KDE Desktop Environment.
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;
  services.xserver.displayManager.gdm.enable = true;
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

  # xmonad
  services.xserver.windowManager = {
    xmonad.extraPackages = p: [
      p.xmonad
      # p.taffybar
      p.xmobar
      p.xmonad-extras
      p.xmonad-contrib
      p.xmonad-volume
      p.xmonad-utils
      p.xmonad-screenshot
      p.xmonad-wallpaper
      p.xmonad-spotify
    ];
    xmonad.enable = true;
    xmonad.enableContribAndExtras = true;
  };

  virtualisation = {
    docker = {
      enable = true;
    };
    virtualbox.host.enable = true;
    virtualbox.host.enableExtensionPack = false;
    anbox.enable = true;
  };
  systemd.services.docker.path = [ pkgs.kmod pkgs.git ];
  
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.alex = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ]; # Enable ‘sudo’ for the user.
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

}

