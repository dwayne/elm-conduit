{ caddy, writeShellScript, xdg-utils }:

{ name # The name of the script
, root # The derivation that contains the files to be served
, port ? 8000
}:

writeShellScript name ''
  ${xdg-utils}/bin/xdg-open "http://localhost:${builtins.toString port}" && \
    "${caddy}/bin/caddy" file-server --browse --root "${root}" --listen :${builtins.toString(port)}
''
