{
  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    clientMaxBodySize = "1g"; # gitlab
    virtualHosts."4ge.me" = {
      forceSSL = true;
      enableACME = true;
      locations."/".proxyPass = "http://unix:/run/gitlab/gitlab-workhorse.socket:";
    };
    virtualHosts."elk.malfr.at" = {
      basicAuth = { elk = builtins.readFile (./secrets/elk.htpasswd); };
      locations."/".proxyPass = "http://127.0.0.1:5601";
    };
    virtualHosts."vod.px.io" = {
      forceSSL = true;
      enableACME = true;
      locations."/".proxyPass = "http://10.233.1.2:8080";
    };
    virtualHosts."smail.malfr.at" = {
      forceSSL = true;
      enableACME = true;
      locations."/".proxyPass = "http://10.233.2.2:8080";
      extraConfig = ''
        add_header 'Access-Control-Allow-Origin' '*';
        add_header 'Access-Control-Allow-Credentials' 'true';
        add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
        add_header 'Access-Control-Allow-Headers' 'Content-Type, *';
      '';
    };
    virtualHosts."gce2b.xn--wxa.to" = {
      forceSSL = true;
      enableACME = true;
      basicAuth = { ce2 = builtins.readFile (./secrets/gce2b.htpasswd); };
      serverAliases = [ "gce2b.px.io" ];
      root = "/var/www/gce2b";
    };
    virtualHosts."alexandre.peyroux.io" = {
      forceSSL = true;
      enableACME = true;
      serverAliases = [ "alex.px.io" ];
      root = "/var/www/alexandre.peyroux.io";
    };
    virtualHosts."spof.malfr.at" = {
      forceSSL = true;
      enableACME = true;
      default = true;
    };
    virtualHosts."spof.px.io" = {
      forceSSL = true;
      enableACME = true;
      locations."/~alex".alias = "/var/www/alexandre.peyroux.io";
    };
  };
}
