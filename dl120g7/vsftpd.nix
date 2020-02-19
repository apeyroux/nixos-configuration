{
  containers.ftpdcam88 = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "10.10.0.1";
    localAddress = "10.10.0.2";
    bindMounts."/home/cam88" = {
      hostPath = "/home/alex/cam88";
      mountPoint = "/home/cam88";
      isReadOnly = false;
    };
    config = { config, pkgs, ... }: {

        users.extraUsers.cam88 = {
            isNormalUser = true;
            extraGroups = [ "ftp" ];
        };

        services.vsftpd.extraConfig = ''
pasv_enable=Yes
pasv_min_port=10000
pasv_max_port=10010
'';
        services.vsftpd.enable = true;
        services.vsftpd.writeEnable = true;
        services.vsftpd.localUsers = true;
        services.vsftpd.chrootlocalUser = false;
        networking.firewall.allowedTCPPorts = [ 21 ];
        networking.firewall.allowedTCPPortRanges = [ { from=10000; to=10010; } ]; # mode pasv
    };
  };
}
