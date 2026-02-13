{ caddy, writeShellScript, xdg-utils }:

{ name # The name of the script
, root # The derivation that contains the files to be served
, port ? 8000
, config ? null
}:

let
  runCaddy =
    if builtins.isNull config then
      ''
      ${caddy}/bin/caddy file-server --browse --root ${root} --listen :${builtins.toString port}
      ''
    else
      ''
      port=${builtins.toString port} root=${root} ${caddy}/bin/caddy run --config ${config} --adapter caddyfile
      '';
in
writeShellScript name ''
  ${xdg-utils}/bin/xdg-open http://localhost:${builtins.toString port} && ${runCaddy}
''
