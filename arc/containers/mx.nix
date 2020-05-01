{
  containers.mx = {
    autoStart = true;
    privateNetwork = true;
    hostBridge = "br0";

    bindMounts."/mx" = {
      hostPath = "/mx";
      mountPoint = "/mx";
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

      services.prometheus = {
        enable = true;
        exporters = {
          postfix = {
            enable = true;
            systemd.enable = true;
            showqPath = "/var/lib/postfix/queue/public/showq";
            user = "root";
          };
        };
      };
      
      services.fail2ban = {
        enable = true;
        jails = {
          postfix = ''
            filter      = postfix.px
            mode        = aggressive
            action      = iptables-multiport[name=SMTP, port="http,https,smtp,submission,pop3,pop3s,imap,imaps,sieve", protocol=tcp]
          '';
        };
      };

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
          message_size_limit = "0";
          mailbox_size_limit = "0";
          smtpd_error_sleep_time = "1s";
          smtpd_soft_error_limit = "10";
          smtpd_hard_error_limit = "20";
          smtpd_helo_restrictions = [
            "permit_mynetworks"
            "check_sender_access hash:/mx/sender_checks"
            "reject_non_fqdn_hostname"
            "reject_invalid_hostname"
            "permit"
          ];
          smtpd_recipient_restrictions = [
            "permit_sasl_authenticated"
            "reject_invalid_hostname"
            "reject_non_fqdn_hostname"
            "reject_non_fqdn_sender"
            "reject_non_fqdn_recipient"
            "reject_unknown_sender_domain"
            "reject_unknown_recipient_domain"
            "permit_mynetworks"
            "reject_rbl_client sbl.spamhaus.org"
            "reject_rbl_client cbl.abuseat.org"
            "reject_rbl_client dul.dnsbl.sorbs.net"
            "permit"
          ];
        };
        hostname = "mx.px.io";
        destination = ["$myhostname" "$mydomain" "localhost" "px.io" "dev.px.io" "peyroux.io" "xn--wxa.email" "4ge.me"];
        localRecipients = ["@px.io"];
        relayDomains = ["@px.io" "@dev.px.io" "@peyroux.io" "@xn--wxa.email" "@4ge.me"];
        lookupMX = true;
        virtual = builtins.readFile(../secrets/postfix.virtual);
        transport = builtins.readFile(../secrets/postfix.transport);
        sslCert = "/var/lib/acme/mx.px.io/cert.pem";
        sslKey = "/var/lib/acme/mx.px.io/key.pem";
      };
    };
  };
}
