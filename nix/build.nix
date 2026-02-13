{ brotli
, callPackage
, dart-sass
, html-minifier
, lib
, runCommand
, zopfli

, buildElmApplication
}:

{ name
, optimizeHtml ? false
, optimizeCss ? false
, optimizeJs ? false
, compress ? false
, includeRedirects ? false
}:

let
  fs = lib.fileset;

  buildHtmlScript =
    if optimizeHtml then
      ''
      html-minifier                         \
        --collapse-boolean-attributes       \
        --collapse-inline-tag-whitespace    \
        --collapse-whitespace               \
        --decode-entities                   \
        --minify-js                         \
        --remove-comments                   \
        --remove-empty-attributes           \
        --remove-redundant-attributes       \
        --remove-script-type-attributes     \
        --remove-style-link-type-attributes \
        --remove-tag-whitespace             \
        --file-ext html                     \
        --input-dir "$src/html"             \
        --output-dir "$out"
      ''
    else
      ''
      cp "$src/html/"*.html "$out"
      '';

  buildCssScript =
    if optimizeCss then
      ''
      sass --style=compressed --no-source-map "$src/sass/index.scss" "$out/index.css"
      ''
    else
      ''
      sass --embed-sources "$src/sass/index.scss" "$out/index.css"
      '';

  elmOptions =
    if optimizeJs then
      {
        enableOptimizations = true;
        optimizeLevel = 2;

        doMinification = true;
        useTerser = true;
        outputMin = "app.js";
      }
    else
      {
        enableDebugger = true;
      };

  js = buildElmApplication ({
    name = "${name}-js";
    src = fs.toSource {
      root = ../.;
      fileset = fs.unions [
        ../review
        ../src
        ../tests
        ../elm.json
      ];
    };
    elmLock = ../elm.lock;
    output = "app.js";
    doElmFormat = true;
    elmFormatSourceFiles = [ "review/src" "src" "tests" ];
    doElmTest = true;
    doElmReview = true;
  } // elmOptions);
in
runCommand name {
  nativeBuildInputs = [
    brotli
    dart-sass
    html-minifier
    zopfli
  ];

  src = fs.toSource {
    root = ../.;
    fileset = fs.unions (
      [
        ../html
        ../images
        ../sass
      ]
      ++ lib.optional includeRedirects ../config/_redirects
    );
  };
} ''
  mkdir "$out"

  cp -r "$src/images" "$out"
  ${buildHtmlScript}
  ${buildCssScript}
  cp "${js}/app.js" "$out"

  ${lib.optionalString compress ''
    cd "$out" && find . \( -name '*.html' -o -name '*.css' -o -name '*.js' \) -exec brotli "{}" \; -exec zopfli "{}" \;
  ''}

  ${lib.optionalString includeRedirects ''
    cp "$src/config/_redirects" "$out"
  ''}
''
