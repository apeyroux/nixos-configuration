{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./containers/plex.nix
      ./containers/gitlab.nix
      ./containers/transmission.nix
      ./containers/nextcloud.nix
      ./containers/mx.nix
      ./nginx.nix
    ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.copyKernels = true;
  boot.loader.grub.device = "/dev/sdb"; # or "nodev" for efi only
  boot.zfs.enableUnstable = true;
  boot.supportedFilesystems = ["zfs"];
  boot.tmpOnTmpfs = true;
  boot.initrd.network = {
    enable = true;
    ssh = {
      enable = true;
      port = 2222; 
      hostECDSAKey = /boot/initrd-ssh-key;
      authorizedKeys = [''
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCjI+cLq05P+BVokJa9MCZK3WniQ/0Bl1gTc5NeH4CuG92qPhTT617IAf8qr6+J5Vy4tFhF3LfyuqlUey6X2oyXlOhz7lDR5q7Wpe/piwSIu1HMQ6iCxbUrZlklMErO24cl0tguVXoq3k9rVPOtlOkCp2YKz5pir8fsJon+CHsuJf+A9aUydK0qVPIxOAiRBjWrQun83mM2t3CkcvSEpjA7JmuzCvbbpiUudmnQz0HqIc4dDSbmkuNMpdqoqGoDkmcNLOYppt5LYDEQZO8EEPXXDSX0fHdTmm6e9Nrjfh2jrquP2NOFLtffEcVrRR5HLNAQCC1seqhyTS4MIDOu+TWCm3JI0WTdaIO2WCItCDFc4Q2Rad5XGD3WFe2I+uB0rhrpu2+Ens5UXTgHB3aXhHEo7F61ZO5SzLHvd4eNvsCaIljVx4Ces0N3Ttxg4yXxVMF8XejQxikx2F6Mx/+dzd0LQQh/B72suOfx/Dbmhrt3VG65E+WtJ6fQ0vOtkZn5h8xAqN6v1wfbpm2WXMUp3IGfV4mo7wEsyHGgj6tpLL1UcIfP4c1iC3bORwGgFWvHgcc7lJZt2EMoo9jekLD/MAvdzT13iWpljGaZ0JwpElhVoQ4IQhEnPgPRyWYhkaAdywqERUggPPqgKaa6CuSaM1uqCUKqqa/pUJR1lX7dpdkeJQ==
      ''];
     };
     postCommands = ''
       echo "zfs load-key -a; killall zfs >> /root/.profile"
     '';
   };
  boot.kernelParams = ["ip=:::::eth0:dhcp"];
  boot.kernel.sysctl = { "net.ipv4.ip_forward" = true; };
  boot.initrd.postMountCommands = ''
    ip addr flush dev eth0
    ip link set eth0 down
  '';

  networking.hostName = "arc.px.io";
  networking.hostId = "3b4c9e86";

  networking.nameservers = [ "1.1.1.1" "8.8.8.8" "8.8.4.4" ];
  networking.dhcpcd.enable = false;
  networking.enableIPv6 = false;
  networking.useDHCP = false;

  # networking.interfaces = {
  #   eth0 = { ipv4 = { addresses = [ { address = "163.172.21.189"; prefixLength = 24; } ]; }; };
  # };
  networking.bridges.br0.interfaces = ["eno1"];
  networking.interfaces.br0.macAddress = "14:18:77:5f:20:12";
  networking.interfaces.br0.ipv4.addresses = [
    { address = "163.172.21.189"; prefixLength = 24; }
    # { address = "212.129.57.42"; prefixLength = 32; }
  ];
  networking.defaultGateway = { address = "163.172.21.1"; interface = "br0"; };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 80 22 443 32400 3005 8324 32469 8081 ];
  networking.firewall.allowedUDPPorts = [ 1900 5353 32410 32412 32413 32414 ];
  # networking.firewall.allowPing = true;
  # Or disable the firewall altogether.
  networking.firewall.enable = true;
  # networking.firewall.trustedInterfaces = [ "br0" ];

  networking.nat = {
    enable=true;
    internalInterfaces=["ve-+" "vb-+"];
    internalIPs = ["212.129.57.42/32"];
    externalInterface = "br0";
    forwardPorts = [
	# TCP
       # { destination = "${config.containers.plex.localAddress}:32400"; sourcePort = 32400; proto = "tcp";}
       # { destination = "${config.containers.plex.localAddress}:2222"; sourcePort = 22; proto = "tcp";}
       # { destination = "${config.containers.plex.localAddress}:3005"; sourcePort = 3005; proto = "tcp";}
       # { destination = "${config.containers.plex.localAddress}:8324"; sourcePort = 8324; proto = "tcp";}
       # { destination = "${config.containers.plex.localAddress}:32469"; sourcePort = 32469; proto = "tcp";}

	# UDP
	# allowedUDPPorts = [ 1900 5353 32410 32412 32413 32414 ];
       # { destination = "${config.containers.plex.localAddress}:1900"; sourcePort = 1900; proto = "udp";}
       # { destination = "${config.containers.plex.localAddress}:5353"; sourcePort = 5353; proto = "udp";}
       # { destination = "${config.containers.plex.localAddress}:32410"; sourcePort = 32410; proto = "udp";}
       # { destination = "${config.containers.plex.localAddress}:32412"; sourcePort = 32412; proto = "udp";}
       # { destination = "${config.containers.plex.localAddress}:32413"; sourcePort = 32413; proto = "udp";}
       # { destination = "${config.containers.plex.localAddress}:32414"; sourcePort = 32414; proto = "udp";}
       # { destination = "${config.containers.plex.localAddress}:1900"; sourcePort = 1900; proto = "udp"; }
      # { destination = "${config.containers.plex.localAddress}:10000-10010"; sourcePort = "10000:10010"; } # FTP PASV
    ];
  };

  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "fr";
    defaultLocale = "fr_FR.UTF-8";
  };

  time.timeZone = "Europe/Paris";

  environment.systemPackages = with pkgs; [
    vim
  ];

  services.openssh.enable = true;
  services.openssh.forwardX11 = true;
  services.fail2ban.enable = true;
  services.zfs.autoSnapshot.enable = true;

  programs = {
    mosh.enable = true;
    tmux.enable = true;
    tmux.aggressiveResize = true;
    tmux.baseIndex = 1;
    tmux.historyLimit = 10000;
    tmux.shortcut = "b";
    # programs.tmux.terminal = "screen-256color";
    # programs.tmux.terminal = "xterm-24bits";
    tmux.clock24 = true;
    tmux.extraTmuxConf = ''
run-shell ~/src/tmux-yank/yank.tmux
    '';
  };

  virtualisation.docker.enable = true;

  users.users.alex = {
    password = "alex";
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ]; # Enable ‘sudo’ for the user.
  };

  security.sudo.wheelNeedsPassword = false;

  nixpkgs.config.allowUnfree = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  nix.trustedUsers = ["root" "alex"];
  system.autoUpgrade.enable = true;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?

}
