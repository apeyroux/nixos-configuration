{ config, pkgs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.grub.enable = false;
  boot.initrd.luks.devices = [{device="/dev/mmcblk0p3"; name="sroot"; preLVM=true;}];
  boot.cleanTmpDir = true;
  boot.tmpOnTmpfs = true;

  networking.hostName = "lapy.xn--wxa.computer"; # Define your hostname.
  networking.firewall.enable = true;
  networking.networkmanager.enable = true;
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "fr";
    defaultLocale = "fr_FR.UTF-8";
  };
  time.timeZone = "Europe/Paris";

  services.acpid.lidEventCommands = "slimlock";

  services.xserver.enable = true;
  services.xserver.autorun = true;
  services.xserver.layout = "fr";
  services.xserver.xkbOptions = "eurosign:e";
  services.xserver.libinput.enable = true;
  services.xserver.displayManager.slim.enable = true;
  # xmonad
  services.xserver.windowManager = {
    # i3.enable = true;
    xmonad.enable = true;
    xmonad.enableContribAndExtras = true;
    default = "xmonad";
  };

  users.extraUsers.alex = {
    isNormalUser = true;
    password = "changeme";
    extraGroups = ["wheel"
                   "networkmanager"
                   ];
  };

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    dmenu
    git
    google-chrome
    haskellPackages.xmobar
    htop
    mosh
    terminator
    tmux
    xorg.xbacklight
  ];
  programs.bash.enableCompletion = true;
  programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  system.stateVersion = "17.09";

}
