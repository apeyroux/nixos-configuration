# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    <nixos-hardware/lenovo/thinkpad/p53>
    <nixos-hardware/common/pc/laptop/ssd>
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernel.sysctl = { "net.ipv4.ip_forward" = true; };

  networking.hostId = "8cdadb71";
  networking.hostName = "p53"; # Define your hostname.
  networking.domain = "px.io";
  networking.hosts = import ./secrets/hosts.nix;
  networking.firewall.enable = false;
  networking.networkmanager.enable = true;
  networking.nameservers = ["1.1.1.1" "1.0.0.1" "8.8.8.8" "4.4.4.4"];
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
  # services.xserver.displayManager.startx.enable = true;
  services.xserver.displayManager.lightdm.enable = true;

  # services.logind.lidSwitch = "ignore";
  
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

  fonts.fonts = with pkgs; [
    roboto
    roboto-mono
    fira
    fira-mono
    fira-code
    fira-code-symbols
    font-awesome
    font-awesome-ttf
  ];
  
  # Configure keymap in X11
  services.xserver.layout = "fr";
  services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  services.zfs.autoSnapshot.enable = true;
  services.pcscd.enable = true;

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
  #   security.pki.certificates = [
  #     ''
  # -----BEGIN CERTIFICATE-----
  # MIIGfjCCBGagAwIBAgIUbylhg5qxWg74fFS25nU/yEaRRz0wDQYJKoZIhvcNAQEL
  # BQAwcDELMAkGA1UEBhMCRlIxDDAKBgNVBAgMA0lMTTEMMAoGA1UEBwwDSUxNMRIw
  # EAYDVQQKDAlER0dOIEZBS0UxMTAvBgNVBAMMKGZha2UtZ2VuZGFybWVyaWUuZGV2
  # L2FkbWluQGZha2UtZ2VuZC5kZXYwHhcNMjEwMzE5MTc0NDIxWhcNMzEwMzE3MTc0
  # NDIxWjBUMQswCQYDVQQGEwJGUjEMMAoGA1UECAwDSUxNMQwwCgYDVQQHDANJTE0x
  # DTALBgNVBAoMBERHR04xGjAYBgNVBAMMESouZ2VuZGFybWVyaWUuZGV2MIICIjAN
  # BgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAs6p3ZXD0J/f+wSPpIL+cKOPWMGET
  # 8+z78IKUNZcFSxUxs8FuB98ci8Rn5fLKVclGtF1RrjWhFIVi1Ttu4SJkZFkGCkiZ
  # yoj66FY9dxFiunR6Ktd8XQ8UQgMhB1h4tamnLSV/K8zNzDa63qfutcnD0Bbvs5eC
  # jeMqj2OMOClTqbylLQih0wYsPo8rDIV8D30MbZ+G1o0aKP6fc7OzwsBBo0Gqc1ZW
  # JSmCEY+Jy9TVboGNEg3uzXMGF2/2Tn6zEIl7jX8h7LP054eBzmhJns8u2u6F8KlO
  # rvMCZsR3nYDXNBebek0i7SKsmFm1CJR3yO2gqqMXLwOQd4femjmWHJ7u6sh/w3ut
  # wB1zp7oNVD10N/nunwhZASGe62trzT9yKwAu7UdgtedLrct5pJmRmaw8ncKnzh5+
  # 7feVXk2j2LX3uxd2NRx/PCjbRL5f37rRkFexhD+o0GxEYalGnsrWgaXHYr+kAZnT
  # Msk+ldeAgumeByFQ3qoWCMT0UbG4L084irT10qU7rblbjskoMWoxobDkQ+LWVMdh
  # WSjlFTG5aJTgG/GBdUXBn05al99jeQzn5zkGmqoukpIUHhEIVjH1CawDQOWIqnHN
  # jdt8FhtnRtNHqj+j4TB/oHzgs/OzEK9d/WJT2Xqf8eyiclVLPVI3Jt8tiSxiKzsR
  # K3NHNsy8BGIpCx8CAwEAAaOCASowggEmMIGXBgNVHSMEgY8wgYyhdKRyMHAxCzAJ
  # BgNVBAYTAkZSMQwwCgYDVQQIDANJTE0xDDAKBgNVBAcMA0lMTTESMBAGA1UECgwJ
  # REdHTiBGQUtFMTEwLwYDVQQDDChmYWtlLWdlbmRhcm1lcmllLmRldi9hZG1pbkBm
  # YWtlLWdlbmQuZGV2ghRbUqIW7DatYEDw84+EvRpQEe5GPTAJBgNVHRMEAjAAMAsG
  # A1UdDwQEAwIE8DByBgNVHREEazBpghEqLmdlbmRhcm1lcmllLmRldoIVKi5rcmIu
  # Z2VuZGFybWVyaWUuZGV2ghgqLnNzb21jZS5nZW5kYXJtZXJpZS5kZXaCEiouZG9j
  # a2VyLmxvY2FsaG9zdIIJbG9jYWxob3N0hwR/AAABMA0GCSqGSIb3DQEBCwUAA4IC
  # AQB9EaxLFSrAMadYhwlyeK5Ahf3VzQql448WNJy6YMi+dZ3d+0Uht3MmW4e0D5fV
  # NfMDqg1XhZiwze6YJDfPlZ/hvXFDVbdpyM/WqzCHBjwu0woAtNDYLicxEDKTfT2u
  # qW7j5SBSHoZaDVsz0kg7GEZ7kyq6VIWKlNs94bTBa19+BcaX0dxy+rVOuoacZ7ST
  # YC0otXYxmOdtSGz8PqiEtaRyR1ETGFEsIfsGlvfBPFBgGZls8hw9fY0tpXpOOLWX
  # javqfhZUdwEKZX8Vg2UKU2p5FAAkNlAiGcKJ42yJ724uIJAH0G77WDC20uTAgjA7
  # Cqw+S7h3Tp69vnSpFBRwYKd+gdDXpUAecU5UwRL9O1HE7IYBuVUv9gsSke8+pCUV
  # wU8aO9X8ibgNO46teYVyb6QN090xdyZi2uhIQxIWU8ATa4aOVfgbNvOcsQXSS6P3
  # Pj6mUCCZxcKeaFSaY4ELkJsEkG/lBLIXFK1yGkZ72xqv2/j1EMzZWDLOcFbsnT/R
  # /GFYV+OdaK0oRA6X4fl5iGqpasmYAOSqyndgxqfelwiqMP143VBbYPgH/F7Zx1YA
  # AMmmJhyL5FaUCY6QWM6STDml7ETAdwqwFRfQw3fvHJHcEsMSUKmj9lGSghapp6Qu
  # 9JVcc0t9ougwOmSlDgFzHTcMMD7iA69PWDU/ORcFEGhN+Q==
  # -----END CERTIFICATE-----
  # -----BEGIN CERTIFICATE-----
  # MIIFZzCCA08CFFtSohbsNq1gQPDzj4S9GlAR7kY9MA0GCSqGSIb3DQEBBQUAMHAx
  # CzAJBgNVBAYTAkZSMQwwCgYDVQQIDANJTE0xDDAKBgNVBAcMA0lMTTESMBAGA1UE
  # CgwJREdHTiBGQUtFMTEwLwYDVQQDDChmYWtlLWdlbmRhcm1lcmllLmRldi9hZG1p
  # bkBmYWtlLWdlbmQuZGV2MB4XDTIxMDMxOTE3NDQyMFoXDTMxMDMxODE3NDQyMFow
  # cDELMAkGA1UEBhMCRlIxDDAKBgNVBAgMA0lMTTEMMAoGA1UEBwwDSUxNMRIwEAYD
  # VQQKDAlER0dOIEZBS0UxMTAvBgNVBAMMKGZha2UtZ2VuZGFybWVyaWUuZGV2L2Fk
  # bWluQGZha2UtZ2VuZC5kZXYwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoIC
  # AQCrlCXUigOkIJ4cD7yN8fzYdT6vWlK9hDPVDPwP9IHe3GRfb2vrB/Zg3+kGcoWw
  # mBfKNR7ypmjMQ/rZ+rHGj+afxHef+Iro1R9pNTGuJu3uVii5ZDZScxtoXnK/NL9b
  # KlmG5WAIJgrSgXx++26iEmCzVu/jCcb9SBL8jUyrqcNbRzNfnE7UamCQ23zI2PVz
  # SkLXGyDuVOFjOQVE55mzH9/H1lm06Lu5E+4d/SNecyzsfdJMCtqEGc7iSgdrM88f
  # TfPLElH9sSwFU1aiwONAUioba1L2MfJoAVzvs1hMhBQSBdmQSs6pEQrsNThDcP2R
  # ZsG88DAEtwdihpzXVOHH0iSiNEPUYrnxFJZltk7tCOL1q+R3+NJ5rNZv8C1P21dR
  # bmbN8PL9Ta8CrEBrjFrx4PATrdA8zDBLNwJb22WamVf9rhd1UgLyvP1F/Oivf0z+
  # fcvbRsbyWm1aYL1i+WfOzdbCa330IhL1f5WLCo5DVU4BQIMx4fZdqhTn95ilan0J
  # ePfM6KJDcOVdCQjkfQg3qRIeUCl7/uUy/7eeltzu6Dut7NNVzXNB9zOF6X3ejt9Z
  # 1Db1PCfooCgSNWSeP9PStZTXAj8qNkVgoggm2xN2ECG6GLQumcxVbx3g+KBtHgJN
  # /k5kZPwuWBd6z/dyZcB2FAzJoUNpeRNZH+hbFsNQjSKi/wIDAQABMA0GCSqGSIb3
  # DQEBBQUAA4ICAQB4aSB3pKBEGhHb/L3+HoqByEWJsX3m8gYoZro7uMfwRcNmGit6
  # uUYL8hP9s7yAjpEL76X7KBJfBj7vWY0aOWT8oruxOWlbNfO/rDfH3GMcxhUW4CmN
  # GBAl7XVNayrrogUgZg9fZi7imtClzH0jI9y33o3AJgKvXWq/o//nzok5WkVXYcLR
  # f0vFC2a/GUNZ/8hkFPKdD1DC43jvjVECdIswiNLvVWKT6DHpLMFAdeH7WI9g9pBO
  # gMGRYORjE8Jigmyzvc//AL4+wJ7uSo9uYetL+OhkdLsM5xG2gNGrUSwYySIJXhvM
  # ELDKcD3YpfOgoC4BEidNhr68eqQCNRGMZiMlHBzbbacKzhAyjFbKZXi+F5M6DWQa
  # DVkFrOUgTwX2uiYxpN6xm8lbhAWPsY7/YLkgKtw5OwUGlTQSbtSITejmEt5sqvF+
  # psl0hpY0+KgThXNWd2Dd0EpslOdXzudjqOZDgh7s5aBBdrHXhxFTAocu8i+tnZBl
  # S5ZRYAzR52q8qCu1nH6S6cEQJxOFesVljr+msH0IZRfKxMMceNembaNQ6RWRHllc
  # uUzceHG+RK7Xqw5ufuE8ce8U1abXy9wQwfZa2TO/W3gT92HZyIgUdSNIad0w9P2S
  # fgL6mxQtcyh6HRShre2K6kvwCjhrzvh7IqFAKTnz+hyGpisnteIarWqpqQ==
  # -----END CERTIFICATE-----
  #   ''];
  users.users.alex = {
    hashedPassword = "$6$KjQCNodPNdbgAuvk$U2iGkgg9uZWum7lKWabsxljElXhS5BffzaFprbj66eKft.EA31KchHWE8j9jHnteFt.jOMqNTqQCR.QAVlwD10";
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

  # if docker zfs in hardware.nix:
  # systemd.services.docker.after = ["var-lib-docker.mount"];
  # fileSystems."/var/lib/docker" =
  # { device = "rpool/docker";
  #   fsType = "zfs";
  # };

  virtualisation = {
    podman = {
      enable = true;
    };
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
  programs.adb.enable = true;
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

