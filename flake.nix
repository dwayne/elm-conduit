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
          includeRedirects = true;
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

        serveDev = serve {
          name = "serve-elm-conduit-dev";
          root = dev;
          port = 8000;
          config = ./config/Caddyfile;
        };

        serveProd = serve {
          name = "serve-elm-conduit-prod";
          root = prod;
          port = 8001;
          config = ./config/Caddyfile;
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

            build-workshop () {
              nix build .#workshop "''${@:--L}"
            }
            alias bw='build-workshop'

            serve-workshop () {
              nix run .#workshop "$@"
            }
            alias sw='serve-workshop'

            build-sandbox () {
              nix build .#sandbox "''${@:--L}"
            }
            alias bs='build-sandbox'

            serve-sandbox () {
              nix run .#sandbox "$@"
            }
            alias ss='serve-sandbox'

            build () {
              nix build "''${@:--L}"
            }
            alias b='build'

            serve () {
              nix run "$@"
            }
            alias s='serve'

            build-prod () {
              nix build .#prod "''${@:--L}"
            }
            alias bp='build-prod'

            serve-prod () {
              nix run .#prod "$@"
            }
            alias sp='serve-prod'

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
            echo "Type 'bw' to build the workshop"
            echo "Type 'sw' to serve the workshop"
            echo ""
            echo "Type 'bs' to build the sandbox"
            echo "Type 'ss' to serve the sandbox"
            echo ""
            echo "Type 'b' to build the development version of the application"
            echo "Type 's' to serve the development version of the application"
            echo ""
            echo "Type 'bp' to build the production version of the application"
            echo "Type 'sp' to serve the production version of the application"
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
          default = self.apps.${system}.dev;

          workshop = mkApp {
            drv = serveWorkshop;
            description = "Serve the Conduit workshop";
          };

          sandbox = mkApp {
            drv = serveSandbox;
            description = "Serve the Conduit sandbox";
          };

          dev = mkApp {
            drv = serveDev;
            description = "Serve the development version of the Conduit web application";
          };

          prod = mkApp {
            drv = serveProd;
            description = "Serve the production version of the Conduit web application";
          };
        };

        checks = {
          inherit
            workshop serveWorkshop
            sandbox serveSandbox
            dev serveDev
            prod serveProd
            ;
        };
      }
    );
}
