{
  containers.plex = {
    autoStart = true;
    # privateNetwork = true;
    # hostAddress = "10.10.10.1";
    # localAddress = "10.10.10.2";
    bindMounts."/plex" = {
      hostPath = "/plex";
      mountPoint = "/home/plex";
      isReadOnly = false;
    };
    config = { config, pkgs, ... }: {

    services.plex = {
      enable = true;
      openFirewall = true;
    };

    # services.openssh.enable = true;
    # services.openssh.permitRootLogin = "yes";
    # services.openssh.openFirewall = true;

    nixpkgs.config.allowUnfree = true;
    nixpkgs.overlays = [ 
     (self: super: {
       plexRaw = super.plexRaw.overrideAttrs (old: rec {
         version = "1.18.5.2309-f5213a238";
         src = super.fetchurl rec {
           url = "https://downloads.plex.tv/plex-media-server-new/${version}/redhat/plexmediaserver-${version}.x86_64.rpm";
           sha256 = "1w8v2v4i4bg3pr8rxxyc1zjkifihv1bhar7pb4dmf2qpbbcx1knw";
         };
        });
      })
    ];
    };
  };
}
