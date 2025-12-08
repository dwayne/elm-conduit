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

        elmConduit = buildElmApplication {
          name = "elm-conduit";
          src = ./.;
          elmLock = ./elm.lock;
          registryDat = ./registry.dat;
          output = "app.js";
        };
      in
      {
        devShells.default = pkgs.mkShell {
          name = "dev";

          packages = [
            elm2nix.packages.${system}.default
          ];

          shellHook = ''
            export PS1="($name) $PS1"
          '';
        };

        packages = {
          inherit elmConduit;

          default = elmConduit;

          debugElmConduit = elmConduit.override { enableDebugger = true; };

          optimizedElmConduit = elmConduit.override {
            enableOptimizations = true;
            doMinification = true;
            useTerser = true;
            #
            # Uglify actually gave smaller file sizes
            #
            doCompression = true;
            doReporting = true;
          };
        };
      }
    );
}
