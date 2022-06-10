let pkgs = import <nixpkgs> { };

in
pkgs.mkShell rec {
  name = "wemark";

  buildInputs = with pkgs; [
    nodejs
  ];
}
