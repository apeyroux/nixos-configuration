{
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
      networking.firewall.allowedTCPPorts = [ 25 80 ]; # 80 only for acme
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

      services.nginx = {
        enable = true;
        virtualHosts."smtp.px.io" = {
          root = "/var/www/smtp.px.io";
          default = true;
        };
      };

      services.saslauthd = {
        enable = true;
      };

      environment.etc."sasl2/smtpd.conf".text = ''
pwcheck_method: auxprop
auxprop_plugin: sasldb
mech_list: PLAIN LOGIN CRAM-MD5 DIGEST-MD5 NTLM
      '';

      services.opendkim = {
        enable = true;
        domains = "csl:px.io,peyroux.io";
        selector = "px";
      };
      
      services.postfix = {
        enable = true;
        config = {
          inet_interfaces = "all";
          smtp_use_tls = true;
          smtpd_tls_auth_only = "yes";
          smtp_sender_dependent_authentication = "yes";
          recipient_delimiter = "+";
          message_size_limit = "0";
          mailbox_size_limit = "0";
          smtpd_sasl_auth_enable = "yes";
          smtpd_sasl_authenticated_header = "yes";
          smtpd_sender_login_maps = "hash:/smtpd/controlled_envelope_senders";
          smtpd_sasl_local_domain = "$myhostname";
          smtp_sasl_mechanism_filter = "plain, login";
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
        hostname = "smtp.px.io";
        destination = ["$myhostname" "$mydomain" "localhost" "px.io" "dev.px.io" "peyroux.io" "xn--wxa.email" "4ge.me"];
        localRecipients = ["@px.io"];
        relayDomains = ["@px.io" "@dev.px.io" "@peyroux.io" "@xn--wxa.email" "@4ge.me"];
        # lookupMX = true;
        # virtual = builtins.readFile(../secrets/postfix.virtual);
        # transport = builtins.readFile(../secrets/postfix.transport);
        sslCert = "/var/lib/acme/smtp.px.io/cert.pem";
        sslKey = "/var/lib/acme/smtp.px.io/key.pem";
      };
    };
  };
}
