{ config, lib, pkgs, ... }:

{ 
  services.nginx = {
    enable = true; 
    virtualHosts = {
      "spof.px.io" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
      	    # proxyPass = "http://localhost:3000";
	    root = "/var/www/spof/";
    	};
      };
    };
  };
}
