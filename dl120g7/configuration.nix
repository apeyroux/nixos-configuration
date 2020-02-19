{ config, pkgs, ... }:

{

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./gitlab.nix
      ./elk.nix
      ./nginx.nix
      ./matomo.nix
      ./vsftpd.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.devices = ["/dev/sda" "/dev/sdb"]; # or "nodev" for efi only
  boot.loader.grub.zfsSupport = true;
  boot.supportedFilesystems = ["zfs"];
  boot.zfs.enableUnstable = true;
  boot.kernelPackages = pkgs.linuxPackages_4_17; # fix driver raid hp
  networking.hostId = "d0cb1eed";

  boot.initrd.network.enable = true;
  boot.initrd.network.ssh.enable = true;
  boot.initrd.network.ssh.hostRSAKey = "/boot/dropbear_rsa_host_key";
  boot.initrd.network.ssh.authorizedKeys = [
  ''ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDK2KWpm3Jch05W45YzQmST6qIbwlZQyBzgtFglnVfTGpSRrOWPX0aZr2p8ktDbepkV5Unm2Bn+3TUThV71nTS3aYRRilNijCXfKoaK0tQbyUvkhLxXdzJRuwVObK9QgdkJR6+5sy56TOnCmPeTuJywXbSnX5DXiKWNyYhdZUxFpz/Dixvuk+lcLe5o31260qtLTII+OWEItBxFC1c8QqbAJQykphJLPVoY7xt/WbJWVaOM6F8rRTuX+F6ifuVCAJA86lSdOXzAIb9SGMPwc8Pjvht7Zx8KSY2XjBpoV6WRwoavEsJlXFMyE8swyRt85IBeep6zoWwL0zNNqQv5Z4LP''
  ''ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCjI+cLq05P+BVokJa9MCZK3WniQ/0Bl1gTc5NeH4CuG92qPhTT617IAf8qr6+J5Vy4tFhF3LfyuqlUey6X2oyXlOhz7lDR5q7Wpe/piwSIu1HMQ6iCxbUrZlklMErO24cl0tguVXoq3k9rVPOtlOkCp2YKz5pir8fsJon+CHsuJf+A9aUydK0qVPIxOAiRBjWrQun83mM2t3CkcvSEpjA7JmuzCvbbpiUudmnQz0HqIc4dDSbmkuNMpdqoqGoDkmcNLOYppt5LYDEQZO8EEPXXDSX0fHdTmm6e9Nrjfh2jrquP2NOFLtffEcVrRR5HLNAQCC1seqhyTS4MIDOu+TWCm3JI0WTdaIO2WCItCDFc4Q2Rad5XGD3WFe2I+uB0rhrpu2+Ens5UXTgHB3aXhHEo7F61ZO5SzLHvd4eNvsCaIljVx4Ces0N3Ttxg4yXxVMF8XejQxikx2F6Mx/+dzd0LQQh/B72suOfx/Dbmhrt3VG65E+WtJ6fQ0vOtkZn5h8xAqN6v1wfbpm2WXMUp3IGfV4mo7wEsyHGgj6tpLL1UcIfP4c1iC3bORwGgFWvHgcc7lJZt2EMoo9jekLD/MAvdzT13iWpljGaZ0JwpElhVoQ4IQhEnPgPRyWYhkaAdywqERUggPPqgKaa6CuSaM1uqCUKqqa/pUJR1lX7dpdkeJQ==''];
  boot.initrd.network.postCommands = ''
       echo "zfs load-key -a; killall zfs" >> /root/.profile
     '';
  boot.kernelParams = ["ip=:::::eth0:dhcp"];
  boot.kernel.sysctl = { "net.ipv4.ip_forward" = true; };

  security.sudo.wheelNeedsPassword = false;

  networking.hostName = "spof.malfr.at"; # Define your hostname.
  networking.hosts = {
    "127.0.1.1" = [ "spof.malfr.at" ];
    "10.10.0.2" = [ "ftpd"] ;
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 80 443 22 ];
  networking.firewall.allowedTCPPortRanges = [ { from=10000; to=10010; } ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  networking.firewall.enable = true;
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" "8.8.4.4" ];

  networking.nat = {
    enable=true;
    internalInterfaces=["ve-+"];
    externalInterface = "eth0";
    forwardPorts = [
      { destination = "10.10.0.2:21"; sourcePort = 2121; }
      { destination = "10.10.0.2:10000-10010"; sourcePort = "10000:10010"; } # PASV
    ];
  };

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "fr";
    defaultLocale = "fr_FR.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget vim kitty
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.bash.enableCompletion = true;
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };
  programs.mosh.enable = true;
  programs.tmux.enable = true;
  programs.tmux.shortcut = "b";
  programs.tmux.terminal = "screen-256color";
  programs.tmux.clock24 = true;
  programs.tmux.baseIndex = 1;
  programs.tmux.keyMode = "emacs";
  programs.tmux.newSession = true;

  # List service
  # services.vsftpd.enable = true;
  # # services.vsftpd.userlist = [ "cam88" ];
  # services.vsftpd.localUsers = true;
  # services.vsftpd.chrootlocalUser = true;

  services.gnome3.gnome-keyring.enable = true; 
  services.openssh.enable = true;
  services.openssh.listenAddresses = [ { addr = "195.154.179.200"; port = 22; } ];
  services.fail2ban.enable = true;
  services.zfs.autoSnapshot.enable = true;

  services.postfix.domain = "mail.malfr.at";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  # services.xserver.enable = true;
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable touchpad support.
  # services.xserver.libinput.enable = true;

  # Enable the KDE Desktop Environment.
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;

  virtualisation = {
    docker.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.alex = {
    isNormalUser = true;
    extraGroups = ["wheel" "docker" "libvirtd" "kvm"];
    uid = 1000;
  };

  # users.extraUsers.cam88 = {
  #  isNormalUser = true;
  #  uid = 1001;
  # };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.autoUpgrade.enable = true;
  system.stateVersion = "18.03"; # Did you read the comment?

}
