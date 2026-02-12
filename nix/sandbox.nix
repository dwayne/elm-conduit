{ lib, runCommand, dart-sass

, buildElmApplication
}:

{ name }:

let
  fs = lib.fileset;

  js = buildElmApplication {
    name = "${name}-js";

    src = fs.toSource {
      root = ../.;
      fileset = fs.unions [
        ../src
        ../elm.json
      ];
    };

    elmLock = ../elm.lock;
    entry = "src/Sandbox.elm";
    output = "app.js";
    enableDebugger = true;
    doElmFormat = true;
  };
in
runCommand "elm-conduit-workshop" {
  src = fs.toSource {
    root = ../.;
    fileset = fs.unions [
      ../images
      ../sandbox
      ../sass
    ];
  };
} ''
  mkdir "$out"

  cp -r "$src/images" "$out"
  cp "$src/sandbox/"*.html "$out"
  ${dart-sass}/bin/sass --embed-sources "$src/sass/index.scss" "$out/index.css"
  cp "${js}/app.js" "$out"
''
