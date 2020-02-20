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
         version = "1.18.6.2368-97add474d";
         src = super.fetchurl rec {
           url = "https://downloads.plex.tv/plex-media-server-new/${version}/redhat/plexmediaserver-${version}.x86_64.rpm";
           sha256 = "0d2nnvw9qpmsra6g044bz192v67igcp1mfayy4sk0j2yqgiqvcgl";
         };
        });
      })
    ];
    };
  };
}
