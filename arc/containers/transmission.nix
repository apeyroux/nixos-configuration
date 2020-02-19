{
  containers.transmission = {
    autoStart = true;
    # privateNetwork = true;
    # hostAddress = "10.10.10.1";
    # localAddress = "10.10.10.2";
    bindMounts."/transmission" = {
      hostPath = "/transmission";
      mountPoint = "/home/transmission";
      isReadOnly = false;
    };
    config = { config, pkgs, ... }: {
  
    networking.firewall.allowedTCPPorts = [ 9091 ];
    services.transmission = {
      enable = true;
      settings = { rpc-host-whitelist = "dwl.px.io"; download-dir = "/home/transmission/dwl"; };
    };

    };
  };
}
