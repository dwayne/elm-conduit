{
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem(system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        workshop = pkgs.callPackage ./nix/workshop.nix {};
      in
      {
        devShells.default = pkgs.mkShell {
          name = "elm-conduit";

          packages = [
          ];

          shellHook = ''
            export PROJECT_ROOT="$PWD"
            export PS1="($name)\n$PS1"
          '';
        };

        packages = {
          inherit workshop;
        };
      }
    );
}
