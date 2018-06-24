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

    listen = mkOption {
      type = with types; listOf (submodule {
        options = {
          addr = mkOption { type = str;  description = "IP address.";  };
          port = mkOption { type = int;  description = "Port number."; default = 80; };
          ssl  = mkOption { type = bool; description = "Enable SSL.";  default = false; };
        };
      });
      default = [];
      example = [
        { addr = "195.154.1.1"; port = 443; ssl = true;}
        { addr = "192.154.1.1"; port = 80; }
      ];
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
        inherit (cfg) listen;
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
      };
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
