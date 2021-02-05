# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    <nixos-hardware/lenovo/thinkpad/p53>
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernel.sysctl = { "net.ipv4.ip_forward" = true; };

  networking.hostId = "8cdadb71";
  networking.hostName = "p53"; # Define your hostname.
  networking.hosts = import ./secrets/hosts.nix;
  networking.firewall.enable = false;
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  time.timeZone = "Europe/Paris";

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
  i18n.defaultLocale = "fr_FR.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "fr";
  };

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
  
  # Enable the GNOME 3 Desktop Environment.
  services.xserver.enable = true;
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.displayManager.gdm.nvidiaWayland = true;
  services.xserver.desktopManager.gnome3.enable = true;

  hardware.nvidia.modesetting.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.prime.sync.enable = true;
  hardware.nvidia.prime.nvidiaBusId = "PCI:1:0:0";
  hardware.nvidia.prime.intelBusId = "PCI:0:2:0";

  hardware.opengl.driSupport32Bit = true; # pour docker nvidia

  services.xserver = {
    xautolock = {
      enable = false;
      time = 5;
      killtime = 20;
      killer = "/run/current-system/systemd/bin/systemctl suspend";
      locker = "${pkgs.i3lock}/bin/i3lock";
    };
    windowManager = {
      xmonad = {
        extraPackages = p: [
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
        enable = true;
        enableContribAndExtras = true;
      };
    };
  };

  # Configure keymap in X11
  services.xserver.layout = "fr";
  services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  services.zfs.autoSnapshot.enable = true;

  # Enable sound.
  # sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  # Monitor plug n play
  # https://github.com/phillipberndt/autorandr/blob/v1.0/README.md#how-to-use
  services.autorandr.enable = true;


  #
  # gpg --export alex@mymail.xxx | base64 /tmp/alex.asc
  # VAULT_ADDR=http://127.0.0.1:8200/ vault operator init -pgp-keys="/home/alex/alex.asc" -key-shares=1 -key-threshold=1
  # (create key.b64 with init --gpg-key result cmd)
  # export VAULT_TOKEN=s.f3oxxxxxxxx
  # cat key.b64 | base64 -d | gpg -dq
  # VAULT_ADDR=http://127.0.0.1:8200/ vault operator unseal
  services.vault = {
    enable = true;
    storageBackend = "file";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.jane = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  # };
  security.sudo.wheelNeedsPassword = false;
  users.users.alex = {
    password = "alex";
    isNormalUser = true;
    extraGroups = [
      "adbusers"
      "audio"
      "cdrom"
      "dialout"
      "disks"
      "docker"
      "fuse"
      "networkmanager"
      "root"
      "sibi"
      "vboxusers"
      "video"
      "wheel"
      "wireshark"
    ];
  };

  virtualisation = {
    docker = {
      enable = true;
      storageDriver = "zfs";
      enableNvidia = true;
    };
    virtualbox.host.enable = true;
    virtualbox.host.enableExtensionPack = true;
    # anbox.enable = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [ gnomeExtensions.dash-to-dock ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "20.09"; # Did you read the comment?

}

