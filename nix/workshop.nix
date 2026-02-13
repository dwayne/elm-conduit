{ lib, runCommand, dart-sass }:

let
  fs = lib.fileset;
in
runCommand "elm-conduit-workshop" {
  nativeBuildInputs = [ dart-sass ];

  src = fs.toSource {
    root = ../.;
    fileset = fs.unions [
      ../images
      ../sass
      ../workshop
    ];
  };
} ''
  mkdir "$out"

  cp -r "$src/images" "$out"
  cp "$src/workshop/"*.html "$out"
  sass --embed-sources "$src/sass/index.scss" "$out/index.css"
''
