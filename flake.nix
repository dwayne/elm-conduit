{
  inputs = {
    elm2nix = {
      url = "git+ssh://git@github.com/dwayne/elm2nix?rev=3fa2c5bb6a1d01b6788369057a9edc46d3c78e72";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = { self, nixpkgs, flake-utils, elm2nix }:
    flake-utils.lib.eachDefaultSystem(system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        mkElmDerivation = (elm2nix.lib.elm2nix pkgs).mkElmDerivation;

        elmConduit = mkElmDerivation {
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

          elmConduitDebug = elmConduit.override { enableDebugger = true; };

          elmConduitOptimized = elmConduit.override {
            enableOptimizations = true;
            enableMinification = true;
            useTerser = true;
            enableCompression = true;
            showStats = true;
          };
        };
      }
    );
}
