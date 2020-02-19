# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nix.maxJobs = 4;

  boot = {
       # boot.loader.gummiboot.enable = true;
       loader.efi.canTouchEfiVariables = true;
       loader.grub.enable = false;
       loader.systemd-boot.enable = true;
       kernelModules = [ "tp_smapi" ];
       extraModulePackages = [ config.boot.kernelPackages.tp_smapi ];
       initrd = {
         luks.devices.sroot = {
	   device="/dev/sda2";
	   preLVM=true;
	 };
	 network.enable = true;
	 network.ssh.enable = true;
	 network.ssh.hostRSAKey = "/boot/id_rsa_boot";
	 network.ssh.authorizedKeys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCjI+cLq05P+BVokJa9MCZK3WniQ/0Bl1gTc5NeH4CuG92qPhTT617IAf8qr6+J5Vy4tFhF3LfyuqlUey6X2oyXlOhz7lDR5q7Wpe/piwSIu1HMQ6iCxbUrZlklMErO24cl0tguVXoq3k9rVPOtlOkCp2YKz5pir8fsJon+CHsuJf+A9aUydK0qVPIxOAiRBjWrQun83mM2t3CkcvSEpjA7JmuzCvbbpiUudmnQz0HqIc4dDSbmkuNMpdqoqGoDkmcNLOYppt5LYDEQZO8EEPXXDSX0fHdTmm6e9Nrjfh2jrquP2NOFLtffEcVrRR5HLNAQCC1seqhyTS4MIDOu+TWCm3JI0WTdaIO2WCItCDFc4Q2Rad5XGD3WFe2I+uB0rhrpu2+Ens5UXTgHB3aXhHEo7F61ZO5SzLHvd4eNvsCaIljVx4Ces0N3Ttxg4yXxVMF8XejQxikx2F6Mx/+dzd0LQQh/B72suOfx/Dbmhrt3VG65E+WtJ6fQ0vOtkZn5h8xAqN6v1wfbpm2WXMUp3IGfV4mo7wEsyHGgj6tpLL1UcIfP4c1iC3bORwGgFWvHgcc7lJZt2EMoo9jekLD/MAvdzT13iWpljGaZ0JwpElhVoQ4IQhEnPgPRyWYhkaAdywqERUggPPqgKaa6CuSaM1uqCUKqqa/pUJR1lX7dpdkeJQ==" ];
         # luks.devices.shome = {
         #   yubikey = {
	 #      storage.path="/sdb2.salt";
	 #      storage.device="/dev/sdb1";
         #      storage.fsType="ext4";
	 #      twoFactor=false;
         #      saltLength=64;	                    
	 #   };
	 #   device="/dev/sdb2";
         # };
         # luks.yubikeySupport = true;
      };
  };

  hardware = {
    bluetooth.enable = true;
    # bumblebee.enable = true;
    pulseaudio.enable = true;
    pulseaudio.package = pkgs.pulseaudioFull;
    # trackpoint support (touchpad disabled in this config)
    trackpoint.enable = true;
    trackpoint.emulateWheel = true;
  };

  # enable volume control buttons
  sound.mediaKeys.enable = true;

  networking = {
    extraHosts = ''
127.0.0.1 hub.local 

127.0.0.1 intranet.***REMOVED***.fr 
127.0.0.1 auth.sso.***REMOVED***.fr
127.0.1.2 intranet.krb.***REMOVED***.fr
127.0.1.3 intranet.sso.***REMOVED***.fr
    '';
    hostName = "spof.xn--wxa.zone";
    networkmanager.enable = true;
  };

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "fr";
    defaultLocale = "fr_FR.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  programs = {
    bash.enableCompletion = true;
  };

  environment.systemPackages = with pkgs; [
    curl
    dmenu
    emacs
    git
    gnupg
    google-chrome
    haskellPackages.xmobar
    haskellPackages.xmonad
    htop
    i3lock
    i3status
    isync
    mosh
    mu
    pigz
    sudo
    tmux
    wget
    powerline-fonts
    nitrokey-app
  ];

  virtualisation = {
    docker.enable = true;
    virtualbox.host.enable = true;
  };

  services = {
    hdapsd.enable = true;
    pcscd.enable = true;
    tlp.enable = true;
    dbus.enable = true;
    openssh.enable = true;
    printing.enable = true;
    gnome3.gnome-keyring.enable = true;
    gnome3.gnome-online-accounts.enable = true;
    gnome3.gnome-documents.enable = true;
    udev.extraRules = ''
ACTION!="add|change", GOTO="u2f_end"

# Yubico YubiKey
KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0113|0114|0115|0116|0120|0402|0403|0406|0407|0410", MODE="0660", GROUP="users", TAG+="uaccess"

# YubiKey 4 OTP+U2F+CCID
SUBSYSTEMS=="usb", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0407", GROUP="users", TAG+="uaccess"

# Happlink (formerly Plug-Up) Security KEY
KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="2581", ATTRS{idProduct}=="f1d0", TAG+="uaccess"

#  Neowave Keydo and Keydo AES
KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1e0d", ATTRS{idProduct}=="f1d0|f1ae", TAG+="uaccess"

# HyperSecu HyperFIDO
KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="096e|2ccf", ATTRS{idProduct}=="0880", TAG+="uaccess"

# Feitian ePass FIDO
KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="096e", ATTRS{idProduct}=="0850|0852|0853|0854|0856|0858|085a|085b", TAG+="uaccess"

# JaCarta U2F
KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="24dc", ATTRS{idProduct}=="0101", TAG+="uaccess"

# U2F Zero
KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="8acf", TAG+="uaccess"

# VASCO SeccureClick
KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1a44", ATTRS{idProduct}=="00bb", TAG+="uaccess"

# Bluink Key
KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="2abe", ATTRS{idProduct}=="1002", TAG+="uaccess"

LABEL="u2f_end"

# Nitrokey U2F
KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0664", GROUP="users", ATTRS{idVendor}=="2581", ATTRS{idProduct}=="f1d0"
# Nitrokey FIDO U2F
KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0664", GROUP="users", ATTRS{idVendor}=="20a0", ATTRS{idProduct}=="4287"

SUBSYSTEM!="usb", GOTO="gnupg_rules_end"
ACTION!="add", GOTO="gnupg_rules_end"

# USB SmartCard Readers
## Crypto Stick 1.2
ATTR{idVendor}=="20a0", ATTR{idProduct}=="4107", ENV{ID_SMARTCARD_READER}="1", ENV{ID_SMARTCARD_READER_DRIVER}="gnupg", GROUP+="users", TAG+="uaccess"
## Nitrokey Pro
ATTR{idVendor}=="20a0", ATTR{idProduct}=="4108", ENV{ID_SMARTCARD_READER}="1", ENV{ID_SMARTCARD_READER_DRIVER}="gnupg", GROUP+="users", TAG+="uaccess"
## Nitrokey Storage
ATTR{idVendor}=="20a0", ATTR{idProduct}=="4109", ENV{ID_SMARTCARD_READER}="1", ENV{ID_SMARTCARD_READER_DRIVER}="gnupg", GROUP+="users", TAG+="uaccess"
## Nitrokey Start
ATTR{idVendor}=="20a0", ATTR{idProduct}=="4211", ENV{ID_SMARTCARD_READER}="1", ENV{ID_SMARTCARD_READER_DRIVER}="gnupg", GROUP+="users", TAG+="uaccess"
## Nitrokey HSM
ATTR{idVendor}=="20a0", ATTR{idProduct}=="4230", ENV{ID_SMARTCARD_READER}="1", ENV{ID_SMARTCARD_READER_DRIVER}="gnupg", GROUP+="users", TAG+="uaccess"

LABEL="gnupg_rules_end"
'';
    xserver = {
      enable = true;
      layout = "fr";
      libinput.enable = true;
      xkbOptions = "eurosign:e";
      # alternatively, touchpad with two-finger scrolling
      windowManager = {
        i3.enable = true;
        xmonad.enable = true;
        xmonad.enableContribAndExtras = true;
        default = "i3";
      };
      desktopManager = {
        gnome3.enable = true;
	xterm.enable = false;
        default = "none";
      };
      resolutions = [
        { x = 2048; y = 1152; }
        { x = 1920; y = 1080; }
        { x = 1600; y = 900; }
	{ x = 1368; y = 768; }
	{ x = 1920; y = 1080; }
	{ x = 2560; y = 1440; }
	{ x = 2880; y = 1620; }
    ];
      displayManager.sessionCommands = "${pkgs.haskellPackages.xmobar}/bin/xmobar &";
    };
  };

  security = {
    sudo.wheelNeedsPassword = false;
  };

  users.extraUsers.alex = {
      isNormalUser = true;
      initialHashedPassword = "93191218324b205ca4e4c0e0a9600759c818f9b908ec9311e9147178701ba04d";
      extraGroups = ["wheel"
                     "networkmanager"
                     "vboxusers"
                     "docker"];
  };

  nixpkgs.config = {
    allowUnfree = true;

    packageOverrides = pkgs: {
      bluez = pkgs.bluez5;
    };

    firefox = {
     enableAdobeFlash = true;
     enableAdobeReader = true;
     enableGoogleTalkPlugin = true;
     enableOfficialBranding = true;
     supportsJDK = true;
    };

    #virtualbox = {
    #  enableExtensionPack = true;
    #  pulseSupport = true;
    #};

    chromium = {
     enablePepperFlash = true; # Chromium's non-NSAPI alternative to Adobe Flash
     enablePepperPDF = true;
    };
  };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "17.03";

}
