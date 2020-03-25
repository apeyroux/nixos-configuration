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
         version = "1.18.8.2527-740d4c206";
         src = super.fetchurl rec {
           url = "https://downloads.plex.tv/plex-media-server-new/${version}/redhat/plexmediaserver-${version}.x86_64.rpm";
           sha256 = "05543nkhmp6wq88vz5cnv3cfd5hbd8rqs1rylfy7njgvb0pxl107";
         };
        });
      })
    ];
    };
  };
}
