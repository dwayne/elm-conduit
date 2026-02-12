{
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem(system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        workshop = pkgs.callPackage ./nix/workshop.nix {};

        serve = pkgs.callPackage ./nix/serve.nix {};

        serveWorkshop = serve {
          name = "serve-elm-conduit-workshop";
          root = workshop;
          port = 9000;
        };

        mkApp = { drv, description }: {
          type = "app";
          program = "${drv}";
          meta.description = description;
        };
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

        apps = {
          workshop = mkApp {
            drv = serveWorkshop;
            description = "Serve the Conduit workshop";
          };
        };
      }
    );
}
