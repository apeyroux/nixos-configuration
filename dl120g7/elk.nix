{ config, pkgs, ... }:

let

  master = (import (fetchTarball https://github.com/NixOS/nixpkgs/archive/master.tar.gz) {});

in {

  services.elasticsearch.enable = true;
  services.elasticsearch.package = pkgs.elasticsearch6;
  
  services.logstash.enable = true;
  services.logstash.package = pkgs.logstash6;
  services.logstash.filterConfig = ''
if [type] == "nginx" {
 grok {
   match => [ "message" , "%{COMBINEDAPACHELOG}+%{GREEDYDATA:extra_fields}"]
   overwrite => [ "message" ]
 }
 mutate {
   convert => ["response", "integer"]
   convert => ["bytes", "integer"]
   convert => ["responsetime", "float"]
 }
 geoip {
   source => "clientip"
   target => "geoip"
   add_tag => [ "nginx-geoip" ]
 }
 date {
   match => [ "timestamp" , "dd/MMM/YYYY:HH:mm:ss Z" ]
   remove_field => [ "timestamp" ]
 }
 useragent {
   source => "agent"
 }
}

if [type] == "syslog" {
  grok {
    match => { "message" => "%{SYSLOGTIMESTAMP:syslog_timestamp} %{SYSLOGHOST:syslog_hostname} %{DATA:syslog_program}(?:\[%{POSINT:syslog_pid}\])?: %{GREEDYDATA:syslog_message}" }
    add_field => [ "received_at", "%{@timestamp}" ]
    add_field => [ "received_from", "%{host}" ]
  }
  mutate {
    add_field => {
      "comm" => "%{_COMM}"
    }
  }
  date {
    match => [ "syslog_timestamp", "MMM  d HH:mm:ss", "MMM dd HH:mm:ss" ]
  }
}
  '';
  services.logstash.inputConfig = ''
    file {
      path => ["/var/spool/nginx/logs/access.log", "/var/spool/nginx/logs/error.log"]
      type => "nginx"
    }
    pipe {
      command => "${pkgs.systemd}/bin/journalctl -f -o json"
      type => "syslog" 
      codec => json {}
    }
  '';
  services.logstash.outputConfig = ''
  elasticsearch { 
      index => "%{type}-%{+dd.MM.YYYY}"
  }
  '';
  services.kibana.enable = true;
  services.kibana.package = pkgs.kibana6;
}
