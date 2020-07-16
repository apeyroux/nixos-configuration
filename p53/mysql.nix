{ pkgs, ... }:

{
  services.mysql = {
    enable = true;
    package = pkgs.mysql;
    bind = "localhost";
    ensureDatabases = ["airflow"];
    extraOptions = ''
      explicit_defaults_for_timestamp = 1
    '';
    ensureUsers = 	[
      {
        name = "airflow";
        ensurePermissions = {
          "airflow.*" = "ALL PRIVILEGES";
        };
      }
    ];
  };
}
