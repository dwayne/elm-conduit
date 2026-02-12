{ lib, runCommand, dart-sass }:

let
  fs = lib.fileset;
in
runCommand "elm-conduit-workshop" {
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
  ${dart-sass}/bin/sass --embed-sources "$src/sass/index.scss" "$out/index.css"
''
