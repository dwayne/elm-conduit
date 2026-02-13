{
  inputs = {
    deploy = {
      url = "github:dwayne/deploy";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    elm2nix = {
      url = "github:dwayne/elm2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = { self, nixpkgs, flake-utils, deploy, elm2nix }:
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

        deployProd = pkgs.writeShellScript "deploy-elm-conduit-prod" ''
          ${deploy.packages.${system}.default}/bin/deploy "$@" ${prod} production
        '';

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
            pkgs.actionlint
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

            check () {
              nix flake check -L
              actionlint
              f --validate
              t
              r
            }
            alias c='check'

            f () {
              elm-format "$PROJECT_ROOT/"{review/src,src,tests} "''${@:---yes}"
            }

            r () {
              elm-review "$PROJECT_ROOT/"{review/src,src,tests} "$@"
            }

            t () {
              elm-test "$@"
            }

            d () {
              nix run .#deploy "$@"
            }

            clean () {
              rm -rf "$PROJECT_ROOT/"{elm-stuff,result}
            }

            echo "Development environment loaded"
            echo ""
            echo "Type 'build-workshop' or 'bw' to build the workshop"
            echo "Type 'serve-workshop' or 'sw' to serve the workshop"
            echo ""
            echo "Type 'build-sandbox' or 'bs' to build the sandbox"
            echo "Type 'serve-sandbox' or 'ss' to serve the sandbox"
            echo ""
            echo "Type 'build' or 'b' to build the development version of the application"
            echo "Type 'serve' or 's' to serve the development version of the application"
            echo ""
            echo "Type 'build-prod' or 'bp' to build the production version of the application"
            echo "Type 'serve-prod' or 'sp' to serve the production version of the application"
            echo ""
            echo "Type 'f' to run elm-format"
            echo "Type 'r' to run elm-review"
            echo "Type 't' to run elm-test"
            echo "Type 'check' or 'c' to run all checks"
            echo "Type 'clean' to remove build artifacts"
            echo ""
            echo "Type 'd' to deploy the production version of the application to Netlify"
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

          deploy = mkApp {
            drv = deployProd;
            description = "Deploy the production version of the Conduit web application";
          };
        };

        checks = {
          inherit
            workshop serveWorkshop
            sandbox serveSandbox
            dev serveDev
            prod serveProd
            deployProd
            ;
        };
      }
    );
}
