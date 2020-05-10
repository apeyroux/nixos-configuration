# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.cleanTmpDir = true;
  boot.tmpOnTmpfs = true;
  boot.kernel.sysctl = { "net.ipv4.ip_forward" = true; };
  boot.kernelParams = ["nouveau.modeset=0"];
  boot.initrd.luks.devices.sroot = {
    device = "/dev/nvme0n1p2";
    preLVM = true;
    gpgCard = {
      encryptedPass = "/boot/smart.key";
      publicKey = "/boot/smart.pub";
    };
  };

  networking.hostName = "p53.px.io"; # Define your hostname.
  networking.networkmanager.enable = true;
  networking.nameservers = ["8.8.8.8" "4.4.4.4" "1.1.1.1" "1.0.0.1"];
  networking.hosts = import ./secrets/hosts.nix;
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  
  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp0s31f6.useDHCP = true;
  networking.interfaces.wlp82s0.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
  };
  console.keyMap = "fr";

  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fontconfig.dpi = 96;
    fonts = with pkgs; [
      corefonts inconsolata lato symbola ubuntu_font_family
      fira-code monoid unifont awesome
    ];
  };

  # Set your time zone.
  time.timeZone = "Europe/Paris";

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

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # environment.systemPackages = with pkgs; [
  #   wget vim
  # ];

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
  networking.firewall.enable = false;

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.pcscd.enable = true;
  services.gnome3.gnome-keyring.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.opengl.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "fr";
  services.xserver.xkbOptions = "eurosign:e";

  # Enable touchpad support.
  services.xserver.libinput.enable = true;

  # services.xserver.displayManager.lightdm.enable = true;
  # services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.nvidiaWayland = true;
  # services.xserver.displayManager.gdm.wayland = false;
  services.xserver.desktopManager.gnome3.enable = true;
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;
  hardware.nvidia.modesetting.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.optimus_prime.enable = true;
  hardware.nvidia.optimus_prime.nvidiaBusId = "PCI:1:0:0";
  hardware.nvidia.optimus_prime.intelBusId = "PCI:0:2:0";

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

  security.sudo.wheelNeedsPassword = false;
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.alex = {
    isNormalUser = true;
    password = "alex";
    extraGroups = ["wheel"
                   "adbusers"
                   "root"
                   "sibi"
                   "disks"
                   "dialout"
                   "wireshark"
                   "audio"
                   "video"
                   "cdrom"
                   "fuse"
                   "networkmanager"
                   "vboxusers"
                   "docker"];
  };

  systemd.services.docker.path = [ pkgs.kmod pkgs.git ];
  virtualisation = {
    docker = {
      enable = true;
      autoPrune.enable = true;
    };
    virtualbox.host.enable = true;
    virtualbox.host.enableExtensionPack = true;
    # anbox.enable = true;
  };
  
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.android_sdk.accept_license = true;

  nix = {
    trustedUsers = ["alex"];
  };
  
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?

}
