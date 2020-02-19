{
  containers.nextcloud = {
    autoStart = true;
    privateNetwork = true;
    hostBridge = "br0";

    bindMounts."/nextcloud" = {
      hostPath = "/nextcloud";
      mountPoint = "/var/lib/nextcloud";
      isReadOnly = false;
    };

    config = { config, pkgs, ... }: {

      networking.firewall.allowedTCPPorts = [ 25 80 443 ];
      networking.firewall.allowPing = true;
      networking.interfaces.eth0.ipv4.addresses = [{address = "195.154.35.90"; prefixLength = 32;}];
      networking.interfaces.eth0.macAddress = "52:54:00:00:c7:ee";
      networking.defaultGateway = { address = "163.172.21.1"; interface = "eth0"; };

      services.nginx.virtualHosts."data.px.io" = {
        forceSSL = true;
        enableACME = true;
      };
      
      services.nextcloud = {
        enable = true;
        https = true;
        hostName = "data.px.io";
        nginx.enable = true;
        maxUploadSize = "10G";
	      config.adminpass = builtins.readFile(../secrets/nextcloud.pass);
      };
    };
  };
}
