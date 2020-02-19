# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./nginx.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

  boot.initrd.luks.devices = [{ device="/dev/sda3"; name="sroot"; preLVM=true;}];

  # ssh dropbear
  boot.initrd.network.ssh.enable = true;
  boot.initrd.network.enable = true;
  boot.initrd.network.ssh.hostRSAKey = "/boot/dropbear_rsa_host_key";
  boot.initrd.network.ssh.authorizedKeys = [
  ''ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDK2KWpm3Jch05W45YzQmST6qIbwlZQyBzgtFglnVfTGpSRrOWPX0aZr2p8ktDbepkV5Unm2Bn+3TUThV71nTS3aYRRilNijCXfKoaK0tQbyUvkhLxXdzJRuwVObK9QgdkJR6+5sy56TOnCmPeTuJywXbSnX5DXiKWNyYhdZUxFpz/Dixvuk+lcLe5o31260qtLTII+OWEItBxFC1c8QqbAJQykphJLPVoY7xt/WbJWVaOM6F8rRTuX+F6ifuVCAJA86lSdOXzAIb9SGMPwc8Pjvht7Zx8KSY2XjBpoV6WRwoavEsJlXFMyE8swyRt85IBeep6zoWwL0zNNqQv5Z4LP ja@laptop''
  ''ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCjI+cLq05P+BVokJa9MCZK3WniQ/0Bl1gTc5NeH4CuG92qPhTT617IAf8qr6+J5Vy4tFhF3LfyuqlUey6X2oyXlOhz7lDR5q7Wpe/piwSIu1HMQ6iCxbUrZlklMErO24cl0tguVXoq3k9rVPOtlOkCp2YKz5pir8fsJon+CHsuJf+A9aUydK0qVPIxOAiRBjWrQun83mM2t3CkcvSEpjA7JmuzCvbbpiUudmnQz0HqIc4dDSbmkuNMpdqoqGoDkmcNLOYppt5LYDEQZO8EEPXXDSX0fHdTmm6e9Nrjfh2jrquP2NOFLtffEcVrRR5HLNAQCC1seqhyTS4MIDOu+TWCm3JI0WTdaIO2WCItCDFc4Q2Rad5XGD3WFe2I+uB0rhrpu2+Ens5UXTgHB3aXhHEo7F61ZO5SzLHvd4eNvsCaIljVx4Ces0N3Ttxg4yXxVMF8XejQxikx2F6Mx/+dzd0LQQh/B72suOfx/Dbmhrt3VG65E+WtJ6fQ0vOtkZn5h8xAqN6v1wfbpm2WXMUp3IGfV4mo7wEsyHGgj6tpLL1UcIfP4c1iC3bORwGgFWvHgcc7lJZt2EMoo9jekLD/MAvdzT13iWpljGaZ0JwpElhVoQ4IQhEnPgPRyWYhkaAdywqERUggPPqgKaa6CuSaM1uqCUKqqa/pUJR1lX7dpdkeJQ==''];
  boot.kernelParams = ["ip=:::::eth0:dhcp"];

  security.sudo.wheelNeedsPassword = false;
  users.extraUsers.alex = {
    isNormalUser = true;
    extraGroups = ["wheel" "docker"];
  };

  networking.hostName = "spof.px.io"; # Define your hostname.
  networking.extraHosts = ''
127.0.0.1 spof spof.xn--wxa.zone spof.px.io
  '';

  programs.bash.enableCompletion = true;
  
  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "fr";
    defaultLocale = "fr_FR.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    vim
    emacs25-nox
    tmux
    mosh
  ];

  virtualisation = {
    docker.enable = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.fail2ban.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 80 443 ];
  networking.firewall.allowedUDPPortRanges = [ { from = 60000; to = 61000; } ];
  networking.firewall.enable = true;

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "17.03";

}
