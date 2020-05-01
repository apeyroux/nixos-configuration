{ config, pkgs, ... }:

let
  smtpdFile = pkgs.writeText "smtpd.conf" ''
pwcheck_method: saslauthd
  '';
in {
  containers.smtpd = {
    autoStart = true;
    privateNetwork = true;
    hostBridge = "br0";

    bindMounts."/smtpd" = {
      hostPath = "/smtpd";
      mountPoint = "/smtpd";
      isReadOnly = false;
    };

    config = { config, pkgs, ... }: {
      networking.firewall.enable = true;
      networking.firewall.allowedTCPPorts = [ 587 80 9154 ]; # 80 only for acme
      networking.firewall.allowPing = true;
      networking.interfaces.eth0.ipv4.addresses = [{address = "51.15.151.173"; prefixLength = 32;}];
      networking.interfaces.eth0.macAddress = "52:54:00:00:cd:41";
      networking.defaultGateway = { address = "163.172.21.1"; interface = "eth0"; };

      security.acme.certs = {
        "smtp.px.io" = {
          email = "postmaster@px.io";
          user = config.services.postfix.user;
          group = config.services.postfix.group;
          allowKeysForGroup = true;
          plugins = [ "cert.pem" "fullchain.pem" "full.pem" "key.pem" "account_key.json" "account_reg.json" ];
          webroot = "/var/www/smtp.px.io";
          postRun = "systemctl restart postfix.service";
        };
      };
      
      systemd.services.postfix.after = [ "acme-selfsigned-certificates.target" ];
      systemd.services.postfix.preStart = ''
      mkdir -p /usr/local/lib/sasl2/
      ln -sf ${smtpdFile} /usr/local/lib/sasl2/smtpd.conf
      '';

      services.fail2ban = {
        enable = true;
        jails = {
          postfix = ''
            filter      = postfix
            mode        = aggressive
            action      = iptables-multiport[name=SMTP, port="http,https,smtp,submission,pop3,pop3s,imap,imaps,sieve", protocol=tcp]
          '';
        };
      };

      services.grafana = {
        enable = true;
        domain = "g.px.io";
        protocol = "http";
        provision = {
          enable = true;
          datasources = [
            {
              name = "smtp.px.io";
              url = "http://smtp.px.io:9090";
              type = "prometheus";
            }
          ];
        };
      };

      services.prometheus = {
        enable = true;
        exporters = {
          postfix = {
            enable = true;
            systemd.enable = true;
            systemd.slice = "postfix";
            showqPath = "/var/lib/postfix/queue/public/showq";
            user = "root";
          };
        };
        scrapeConfigs = [
          {
            job_name = "postfix";
            scrape_interval = "5s";
            static_configs = [
              {
                targets = [
                  "mx.px.io:9154"
                  "mx2.px.io:9154"
                ];
                labels = {
                  alias = "mx.px.io";
                };
              }
              {
                targets = [
                  "smtp.px.io:9154"
                ];
                labels = {
                  alias = "smtp.px.io";
                };
              }
            ];
          }
        ];
      };

      services.nginx = {
        enable = true;
        virtualHosts."smtp.px.io" = {
          root = "/var/www/smtp.px.io";
          default = true;
        };
        virtualHosts."g.px.io" = {
          locations."/" = {
            proxyPass = "http://127.0.0.1:3000";
          };
        };
      };

      services.opendkim = {
        enable = true;
        domains = "csl:px.io,peyroux.io";
        selector = "px";
        user = "postfix";
        group = "postfix";
      };

      services.postfix = {
        enable = true;
        enableSmtp = true;
        enableSubmission = true;
        submissionOptions = {
          smtpd_client_restrictions = "permit_sasl_authenticated,reject";

          smtpd_tls_cert_file = "/var/lib/acme/smtp.px.io/fullchain.pem";
          smtpd_tls_key_file = "/var/lib/acme/smtp.px.io/key.pem";

          smtp_tls_cert_file = "/var/lib/acme/smtp.px.io/fullchain.pem";
          smtp_tls_key_file = "/var/lib/acme/smtp.px.io/key.pem";

          smtpd_tls_loglevel = "1";
          smtpd_tls_received_header = "yes";
          smtpd_tls_security_level = "may";
          smtpd_use_tls = "yes";
          smtp_use_tls = "yes";
          
        };
        hostname = "smtp.px.io";
        sslCert = "/var/lib/acme/smtp.px.io/fullchain.pem";
        sslKey = "/var/lib/acme/smtp.px.io/key.pem";
        destination = ["$myhostname" "$mydomain" "localhost" "px.io" "dev.px.io" "peyroux.io" "xn--wxa.email" "4ge.me"];
        localRecipients = ["@px.io"];
        relayDomains = ["@px.io" "@dev.px.io" "@peyroux.io" "@xn--wxa.email" "@4ge.me"];
        virtual = builtins.readFile(../secrets/postfix.virtual);
        transport = builtins.readFile(../secrets/postfix.transport);
        config = {
          inet_interfaces = "all";
          recipient_delimiter = "+";
          message_size_limit = "0";
          mailbox_size_limit = "0";
          smtpd_sender_login_maps = hash:/smtpd/smtpd_sender_login_maps;
          smtpd_sasl_auth_enable = true;
          # smtpd_sasl_service = "smtpd";
          # smtpd_sasl_authenticated_header = true;
          smtpd_sasl_local_domain = "$myhostname";
          smtpd_error_sleep_time = "1s";
          smtpd_soft_error_limit = "10";
          smtpd_hard_error_limit = "20";
          smtpd_milters = "unix:/run/opendkim/opendkim.sock";
          smtpd_helo_restrictions = [
            "permit_mynetworks"
            "reject_non_fqdn_hostname"
            "reject_invalid_hostname"
            "permit"
          ];
          smtpd_sender_restrictions = [
            "reject_non_fqdn_sender"
            "reject_sender_login_mismatch"
          ];
          smtpd_recipient_restrictions = [
            "permit_sasl_authenticated"
            "reject_sender_login_mismatch"
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
      };
    };
  };
}
