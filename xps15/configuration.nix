{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.zfs.enableUnstable = true;
  boot.supportedFilesystems = ["zfs"];
  boot.cleanTmpDir = true;
  boot.tmpOnTmpfs = true;
  boot.kernel.sysctl = { "net.ipv4.ip_forward" = true; };

  networking.hostId = "8cdadb71";
  networking.hostName = "xps15.px.io";
  networking.networkmanager.enable = true; 
  networking.nameservers = ["8.8.8.8" "4.4.4.4" "1.1.1.1" "1.0.0.1"];
  networking.hosts = import ./secrets/hosts.nix;

  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "fr";
    defaultLocale = "fr_FR.UTF-8";
  };

  time.timeZone = "Europe/Paris";

  environment.systemPackages = with pkgs; [
  ];

  programs = {
    gnupg.agent = { enable = true; enableSSHSupport = true; };
    adb.enable = true;
    bash.enableCompletion = true;
    light.enable = true;
    mtr.enable = true;
    mosh.enable = true;
#     tmux.enable = true;
#     tmux.aggressiveResize = true;
#     tmux.baseIndex = 1;
#     tmux.historyLimit = 10000;
#     tmux.shortcut = "b";
#     # programs.tmux.terminal = "screen-256color";
#     # programs.tmux.terminal = "xterm-24bits";
#     tmux.clock24 = true;
#     tmux.extraTmuxConf = ''
# set -g status-right ' #{battery_status_bg} #{battery_icon} #{battery_percentage} #{battery_remain} #[bg=default] %a %d %h %H:%M '
# set -g @batt_charged_icon ""
# set -g @batt_charging_icon ""
# set -g @batt_attached_icon ""
# set -g @batt_full_charge_icon " "
# set -g @batt_high_charge_icon " "
# set -g @batt_medium_charge_icon " "
# set -g @batt_low_charge_icon " "

# run-shell ${pkgs.tmuxPlugins.battery}/share/tmux-plugins/battery/battery.tmux
#   '';
  };

  fonts = {
   enableFontDir          = true;
   enableGhostscriptFonts = true;
   fonts = with pkgs; [
     corefonts inconsolata lato symbola ubuntu_font_family
     fira-code monoid unifont vistafonts awesome
   ];
  };

  sound.enable = true;
  sound.mediaKeys.enable = true;

  services = {
    gnome3.gnome-keyring.enable = true;
    zfs.autoSnapshot.enable = true;
    zfs.autoScrub.enable = true;
    xserver.updateDbusEnvironment = true;
    xserver.libinput.enable = true;
    dbus.socketActivated = true;
    udisks2.enable = true;
    pcscd.enable = true;
    udev.packages = [ pkgs.libu2f-host pkgs.yubikey-personalization ];
    plex = {
      enable = false;
      openFirewall = true;
    };
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

  hardware = {
    opengl.enable = true;
    u2f.enable = true;
    # bluetooth.powerOnBoot = true;
    # bluetooth.enable = true;
    pulseaudio.enable = true;
    pulseaudio.package = pkgs.pulseaudioFull; # bt audio
    pulseaudio.support32Bit = true;
    firmware = [pkgs.broadcom-bt-firmware];
    # enableAllFirmware = true;
  };

  security = {
    # pam.services.login.u2fAuth = true;
    pam.services.slim.u2fAuth = true;
    pam.services.slimlock.u2fAuth = true;
    sudo.wheelNeedsPassword = false;
  };

  services.xserver.enable = true;
  services.xserver.layout = "fr";
  services.xserver.xkbOptions = "eurosign:e";

  #services.xserver.extraConfig = ''
  #Section "Device"
  #  Identifier  "0x72"
  #  Driver      "intel"
  #  Option      "Backlight"  "intel_backlight"
  #EndSection
  #'';

  services.xserver.resolutions = [
    { x = 2048; y = 1152; }
    { x = 1920; y = 1080; }
    { x = 1600; y = 900; }
    { x = 1368; y = 768; }
    { x = 1920; y = 1080; }
    { x = 2560; y = 1440; }
    { x = 2880; y = 1620; }
  ];

  # xmonad
  services.xserver.windowManager = {
    xmonad.extraPackages = p: [
      p.xmonad
      p.taffybar
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
    default = "xmonad";
  };

  environment.variables = { 
    TERM="screen-24bit"; 
    EDITOR="vim"; 
    VISUAL="vim"; 
  };

  # services.kubernetes.roles = ["master" "node"];
  # services.kubernetes.masterAddress = "kub.xps15.px.io";
  
  services.xserver.desktopManager = {
    xterm.enable = false;
    # xfce.noDesktop = true;
  };
  services.xserver.displayManager.slim.enable = true;
  services.printing.enable = true;

  users.users.alex= {
    password = "alex";
    isNormalUser = true;
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
  
  virtualisation = {
    docker = {
      enable = true;
      storageDriver = "zfs";
    };
    virtualbox.host.enable = true;
    virtualbox.host.enableExtensionPack = true;
    # anbox.enable = true;
  };

  # systemd.services.docker.path = pkgs.lib.mkOverride 10 ((pkgs.lib.getValue pkgs.systemd.services.docker.path) ++ [ pkgs.kmod pkgs.git pkgs.zfs ]);
  systemd.services.docker.path = [ pkgs.kmod pkgs.git pkgs.zfs ];
  
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.android_sdk.accept_license = true;
  nixpkgs.overlays = [ 
    (self: super: {
      appimage-run = super.appimage-run.override {
        extraPkgs = p: with p; [
          at-spi2-core
        ];
      };
      plexRaw = super.plexRaw.overrideAttrs (old: rec {
        version = "1.18.2.2015-5a99a9a46";
        src = super.fetchurl rec {
          url = "https://downloads.plex.tv/plex-media-server-new/${version}/redhat/plexmediaserver-${version}.x86_64.rpm";
          sha256 = "0rx0fl4jwmii0wnkw1h8np6y5m120ibvcs5jq50cll1vwl80swkm";
        };
      });
    })
  ];

  nix = {
    useSandbox = true;
    # binaryCaches = [
    #   "ssh://arc"
    #   "https://cache.nixos.org/"
    #   "https://static-haskell-nix.cachix.org"
    # ];
    # binaryCachePublicKeys = [
    #   "static-haskell-nix.cachix.org-1:Q17HawmAwaM1/BfIxaEDKAxwTOyRVhPG5Ji9K3+FvUU="
    #   "arc:zcdkzn8Q2ihjRuXMKo5thtr3Og6XRpV5Qa1PMP03hHE="
    # ];
  };

  nix.buildMachines = [ {
	  hostName = "arc";
	  system = "x86_64-linux";
	  maxJobs = 8;
	  speedFactor = 2;
	}] ;
	nix.distributedBuilds = true;
  nix.trustedUsers = ["root" "alex"];
	nix.extraOptions = ''
		builders-use-substitutes = true
	'';

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  system.autoUpgrade.channel = https://nixos.org/channels/nixos-19.09;
  system.autoUpgrade.enable = true;
  system.stateVersion = "19.09"; # Did you read the comment?

}

