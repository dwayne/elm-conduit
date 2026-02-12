{
  inputs = {
    elm2nix = {
      url = "github:dwayne/elm2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = { self, nixpkgs, flake-utils, elm2nix }:
    flake-utils.lib.eachDefaultSystem(system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (elm2nix.lib.elm2nix pkgs) buildElmApplication;

        workshop = pkgs.callPackage ./nix/workshop.nix {};

        sandbox = pkgs.callPackage ./nix/sandbox.nix { inherit buildElmApplication; } {
          name = "elm-conduit-sandbox";
        };

        serve = pkgs.callPackage ./nix/serve.nix {};

        serveWorkshop = serve {
          name = "serve-elm-conduit-workshop";
          root = workshop;
          port = 9000;
        };

        serveSandbox = serve {
          name = "serve-elm-conduit-sandbox";
          root = sandbox;
          port = 9001;
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
            elm2nix.packages.${system}.default
          ];

          shellHook = ''
            export PROJECT_ROOT="$PWD"
            export PS1="($name)\n$PS1"
          '';
        };

        packages = {
          inherit workshop sandbox;
        };

        apps = {
          workshop = mkApp {
            drv = serveWorkshop;
            description = "Serve the Conduit workshop";
          };

          sandbox = mkApp {
            drv = serveSandbox;
            description = "Serve the Conduit sandbox";
          };
        };
      }
    );
}
