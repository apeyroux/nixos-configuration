let

in {

  # systemd.services."container@gitlab".serviceConfig = { TimeoutSec = "infinity"; };

  containers.gitlab = {
    autoStart = true;
    privateNetwork = true;
    hostBridge = "br0";

    bindMounts."/gitlab" = {
      hostPath = "/git";
      mountPoint = "/gitlab";
      isReadOnly = false;
    };

    config = { config, pkgs, ... }: {
      networking.firewall.allowedTCPPorts = [ 80 443 22 ];
      networking.firewall.allowPing = true;
      networking.interfaces.eth0.ipv4.addresses = [{address = "212.129.57.42"; prefixLength = 32;}];
      networking.interfaces.eth0.macAddress = "52:54:00:00:c7:bf";
      networking.defaultGateway = { address = "163.172.21.1"; interface = "eth0"; };

      services.openssh.enable = true;
      services.fail2ban.enable = true;
      services.postfix.enable = true;
      services.postfix.domain = "4ge.me";

      services.nginx = {
        enable = true;
        recommendedGzipSettings = true;
        recommendedOptimisation = true;
        recommendedProxySettings = true;
        recommendedTlsSettings = true;
        clientMaxBodySize = "1g"; # gitlab

        virtualHosts."4ge.me" = {
          default = true;
          forceSSL = true;
          enableACME = true;
          root = "/var/www/4ge.me";
          locations."/".proxyPass = "http://unix:/var/run/gitlab/gitlab-workhorse.socket:";
          locations."/".extraConfig = ''
proxy_read_timeout 300;
proxy_connect_timeout 300;
proxy_redirect     off;
proxy_set_header   X-Forwarded-Proto https;
proxy_set_header   X-Real-IP         $remote_addr;
proxy_set_header   X-Forwarded-For   $proxy_add_x_forwarded_for;
          '';
        };
      };

      services.gitlab-runner.enable = true;
      # services.gitlab-runner.package = gitmaster.gitlab-runner;
      services.gitlab-runner.configOptions = {
        concurrent = 10;
        runners = [
          {
            name = "docker-nix";
            url = "https://4ge.me/";
            token = builtins.readFile (../secrets/gitlab-runner.token);
            executor = "docker";
            docker = {
              cache_dir = "";
              disable_cache = true;
              host = "";
              privileged = true;
              image = "nixos/nix";
            };
          }
        ];
      };

      services.gitlab.enable = true;
      # services.gitlab.extraConfig = {
      #   omniauth = {
      #     enabled = true;
      #     allow_single_sign_on = ["github" "google"];
      #     block_auto_created_users = true;
      #   };
      # };
      services.gitlab.https = true;
      services.gitlab.host = "4ge.me";
      services.gitlab.user = "git";
      services.gitlab.group = "git";
      services.gitlab.port = 443;
      services.gitlab.statePath = "/gitlab";
      services.gitlab.databaseCreateLocally = true;
      services.gitlab.databaseUsername = "git";
      services.gitlab.initialRootPasswordFile = ../secrets/services.gitlab.initialRootPasswordFile;
      services.gitlab.secrets.secretFile = ../secrets/gitlab.secretFile;
      services.gitlab.secrets.otpFile = ../secrets/gitlab.secrets.otpFile;
      services.gitlab.secrets.dbFile = ../secrets/gitlab.secrets.dbFile;
      services.gitlab.secrets.jwsFile = ../secrets/gitlab.secrets.jwsFile;
      services.gitlab.smtp.enable = true;
      services.gitlab.smtp.domain = "4ge.me";
      services.gitlab.smtp.username = "git@4ge.me";
      services.gitlab.smtp.address = "smtp.eu.mailgun.org";
      services.gitlab.smtp.passwordFile = ../secrets/smtp.passwordFile;

    };
  };

}
