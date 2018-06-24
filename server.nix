{ hostname, listen }:

{ pkgs, config, ... }:

{

  nixpkgs.overlays = [(pkgsself: pkgssuper: {
    python = pkgssuper.python.override {
      packageOverrides = self: super: {
        squarify = self.callPackage ./squarify.nix {};
      };
    };
    # TODO(nspin) nothing like this should be necessary
    pythonPackages = pkgsself.python.pkgs;
  })];

  services.nginx = {
    enable = true;
    virtualHosts."${hostname}" = {
      inherit listen;
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

}
