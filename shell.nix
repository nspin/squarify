with import <nixpkgs> {};

stdenv.mkDerivation {
  name = "env";
  buildInputs = [
    python3
    python3Packages.pillow
    python3Packages.flask
    uwsgi
  ];
  shellHook = "export PYTHONPATH=$PWD:$PYTHONPATH";
}
