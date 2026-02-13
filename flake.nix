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

        build = pkgs.callPackage ./nix/build.nix { inherit buildElmApplication; };

        dev = build {
          name = "elm-conduit-dev";
        };

        prod = build {
          name = "elm-conduit-prod";
          optimizeHtml = true;
          optimizeCss = true;
          optimizeJs = true;
          compress = true;
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
            pkgs.elmPackages.elm
            pkgs.elmPackages.elm-format
            pkgs.elmPackages.elm-json
            pkgs.elmPackages.elm-review
            pkgs.elmPackages.elm-test
          ];

          shellHook = ''
            export PROJECT_ROOT="$PWD"
            export PS1="($name)\n$PS1"

            clean () {
              rm -rf "$PROJECT_ROOT/"{elm-stuff,result}
            }
            alias c='clean'

            f () {
              elm-format "$PROJECT_ROOT/"{review/src,src,tests} "''${@:---yes}"
            }

            r () {
              elm-review "$PROJECT_ROOT/"{review/src,src,tests} "$@"
            }

            t () {
              elm-test "$@"
            }

            echo "Development environment loaded"
            echo ""
            echo "Type 'c' to remove build artifacts"
            echo "Type 'f' to run elm-format"
            echo "Type 'r' to run elm-review"
            echo "Type 't' to run elm-test"
            echo ""
          '';
        };

        packages = {
          inherit workshop sandbox dev prod;
          default = dev;
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

        checks = {
          inherit
            workshop serveWorkshop
            sandbox serveSandbox
            dev
            prod
            ;
        };
      }
    );
}
