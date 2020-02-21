{
  containers.mx = {
    autoStart = true;
    privateNetwork = true;
    hostBridge = "br0";

    bindMounts."/postfix" = {
      hostPath = "/postfix";
      mountPoint = "/postfix";
      isReadOnly = false;
    };

    config = { config, pkgs, ... }: {
      networking.firewall.allowedTCPPorts = [ 25 80 ]; # 80 only for acme
      networking.firewall.allowPing = true;
      networking.interfaces.eth0.ipv4.addresses = [{address = "51.158.22.25"; prefixLength = 32;}];
      networking.interfaces.eth0.macAddress = "52:54:00:00:ca:bb";
      networking.defaultGateway = { address = "163.172.21.1"; interface = "eth0"; };

      security.acme.certs = {
        "mx.px.io" = {
          email = "postmaster@px.io";
          user = config.services.postfix.user;
          group = config.services.postfix.group;
          allowKeysForGroup = true;
          plugins = [ "cert.pem" "fullchain.pem" "full.pem" "key.pem" "account_key.json" "account_reg.json" ];
          webroot = "/var/www/mx.px.io";
          postRun = "systemctl restart postfix.service";
        };
      };
      
      systemd.services.postfix.after = [ "acme-selfsigned-certificates.target" ];

      services.nginx = {
        enable = true;
        virtualHosts."mx.px.io" = {
          root = "/var/www/mx.px.io";
          default = true;
        };
      };

      services.postfix = {
        enable = true;
        config = {
          inet_interfaces = "all";
          smtp_use_tls = true;
          recipient_delimiter = "+";
          smtpd_helo_restrictions = [
            "permit_mynetworks"
            "check_sender_access hash:/postfix/sender_checks"
            "permit"
          ];
        };
        hostname = "mx.px.io";
        destination = ["$myhostname" "$mydomain" "localhost" "px.io" "dev.px.io" "peyroux.io" "xn--wxa.email" "4ge.me"];
        relayDomains = ["@px.io" "@dev.px.io" "@peyroux.io" "@xn--wxa.email" "@4ge.me"];
        lookupMX = true;
        virtual = builtins.readFile(../secrets/postfix.virtual);
        sslCert = "/var/lib/acme/mx.px.io/cert.pem";
        sslKey = "/var/lib/acme/mx.px.io/key.pem";
      };
    };
  };
}
