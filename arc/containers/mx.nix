{
  containers.mx-px-io = {
    autoStart = true;
    privateNetwork = true;
    hostBridge = "br0";

    config = { config, pkgs, ... }: {
      networking.firewall.allowedTCPPorts = [ 25 ];
      networking.firewall.allowPing = true;
      networking.interfaces.eth0.ipv4.addresses = [{address = "51.158.22.25"; prefixLength = 32;}];
      networking.interfaces.eth0.macAddress = "52:54:00:00:ca:bb";
      networking.defaultGateway = { address = "163.172.21.1"; interface = "eth0"; };

      services.postfix = {
        enable = true;
        config = {
          inet_interfaces = "all";
          smtp_use_tls = true;
        };
        hostname = "mx.px.io";
        destination = ["$myhostname" "$mydomain" "localhost" "px.io" "dev.px.io" "peyroux.io" "xn--wxa.email" "4ge.me"];
        relayDomains = ["@px.io" "@dev.px.io" "@peyroux.io" "@xn--wxa.email" "@4ge.me"];
        lookupMX = true;
        virtual = builtins.readFile(../secrets/postfix.virtual);
      };
    };
  };
}
