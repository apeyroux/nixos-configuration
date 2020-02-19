{ config, lib, pkgs, ... }:

{ 
	services.nginx = {
		enable = true; 
		virtualHosts = {
  			"f.xn--wxa.zone" = {
    			forceSSL = true;
    			enableACME = true;
    			locations."/" = {
      				proxyPass = "http://localhost:3000";
    				};
  			};
		};
	};
}
