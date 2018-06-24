{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.squarify;

in

{
  options.services.squarify = {

    enable = mkEnableOption "Squarify Squarification Server";
    serverName = mkOption {
      type = types.str;
      example = "example.com";
    };
    extraVHostConfig = mkOption {
      type = types.attrs;
      example = ''
        {
          forceSSL = true;
          sslCertificate = /foo/bar/cert.pem;
          sslCertificateKey = /foo/bar/priv.pem;
        };
      '';
    };
  };

  config = {

    nixpkgs.overlays = [(pkgsself: pkgssuper: {
      python = pkgssuper.python.override {
        packageOverrides = self: super: {
          squarify = self.callPackage ./pkg.nix {};
        };
      };
      # TODO(nspin) nothing like this should be necessary
      pythonPackages = pkgsself.python.pkgs;
    })];

    services.nginx = {
      enable = true;
      virtualHosts."${cfg.serverName}" = {
        locations = {
          "/squarify" = {
            extraConfig = ''
              uwsgi_pass unix:${config.services.uwsgi.instance.vassals.squarify.socket};
            '';
          };
          "/" = {
            index = "index.html";
            root = "${pkgs.pythonPackages.squarify}/lib/python3.6/site-packages/squarify/resources";
          };
        };
      } // cfg.extraVHostConfig;
    };

    services.uwsgi = {
      enable = true;
      plugins = [
        "python3"
      ];
      instance = {
        type = "emperor";
        vassals = {
          squarify = {
            type = "normal";
            socket = "${config.services.uwsgi.runDir}/squarify.sock";
            chmod-socket = 666;
            module = "squarify.web:app";
            pythonPackages = self: with self; [
              squarify
            ];
          };
        };
      };
    };

  };
 
}
