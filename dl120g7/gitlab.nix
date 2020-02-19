{ config, pkgs, ... }:

let

  gitmaster = (import (fetchTarball https://github.com/NixOS/nixpkgs/archive/master.tar.gz) {});

in {

  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = super: let self = super.pkgs; in {
      gitlab = super.gitlab.overrideDerivation (old: let version = "10.7.7"; in {
        name = "gitlab-${version}";
        gitlabDeb = pkgs.fetchurl {
          url = "https://packages.gitlab.com/gitlab/gitlab-ce/packages/debian/jessie/gitlab-ce_${version}-ce.0_amd64.deb/download";
          sha256 = "17blhaab34599cw19vz5gv2rilxwpl8wfxyfzhysdi672vc0ahh8";
        };
        src = pkgs.fetchFromGitHub {
          owner = "gitlabhq";
          repo = "gitlabhq";
          rev = "v${version}";
          sha256 = "0zx6hy9zmw7cxsn51wlkj1zm4v7b4ch3p6x248j89qbxp5vfp4hm";
        };
      });
    };
  };

  services.gitlab-runner.enable = true;
  services.gitlab-runner.package = gitmaster.gitlab-runner;
  # services.gitlab-runner.configFile = ./runner-config.toml;
  services.gitlab-runner.configOptions = {
    concurrent = 10;
    runners = [
      {
        name = "nix";
        url = "https://4ge.me/";
        token = "e9d91a3bb06e0a6f278840de39e5f4"; # builtins.readFile (./secrets/runners.docker-nix-1.11.token); # e9d91a3bb06e0a6f278840de39e5f4
        executor = "docker";
        docker = {
          image = "nixos/nix";
        };
      }
    ];
  };

  services.gitlab.enable = true;
  
  services.gitlab.smtp.enable = true;
  services.gitlab.smtp.address = "127.0.0.1";
  services.gitlab.smtp.port = 25;

  services.gitlab.extraConfig = { omniauth = {
      enabled = true;
      allow_single_sign_on = ["github" "google"];
      block_auto_created_users = false;
    };
  };

  # services.gitlab.smtp.username = "git@4ge.me";
  # services.gitlab.extraConfig = { gitlab = { smtp_tls = false; }; smtp_enable_starttls_auto = false; };
  
  services.gitlab.https = true;
  services.gitlab.host = "4ge.me";
  services.gitlab.user = "git";
  services.gitlab.group = "git";
  services.gitlab.port = 443;
  services.gitlab.statePath = "/gitlab";
  services.gitlab.packages.gitaly = gitmaster.gitaly;
  services.gitlab.databasePassword = builtins.readFile (./secrets/gitlab.databasePassword);
  services.gitlab.secrets.secret = builtins.readFile (./secrets/gitlab.secrets.secret);
  services.gitlab.secrets.otp = builtins.readFile (./secrets/gitlab.secrets.otp);
  services.gitlab.secrets.db = builtins.readFile (./secrets/gitlab.secrets.db);
  services.gitlab.secrets.jws = builtins.readFile (./secrets/gitlab.secrets.jws);

}
