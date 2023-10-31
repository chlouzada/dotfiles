{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    (pkgs.writeShellScriptBin "playground" ''
      init() {
        mkdir -p ~/.playground
        mkdir -p ~/.playground/.vscode

        echo "{\"deno.enable\": true,\"deno.lint\": true,\"deno.unstable\": true}" > ~/.playground/.vscode/settings.json
        echo "{\"tasks\": {\"dev\": \"deno run --allow-all --watch main.ts\"}}" > ~/.playground/deno.jsonc
        echo "import moment from 'npm:moment'
export function add(a: number, b: number): number {
  return a + b;
}

// Learn more at https://deno.land/manual/examples/module_metadata#concepts
if (import.meta.main) {
  console.log(\"Add 2 + 3 =\", add(2, 3));

  console.log(\"moment\", moment().format());
}" > ~/.playground/main.ts
      }

      # check if deno is installed
      if ! command -v deno &> /dev/null
      then
        echo "Deno could not be found"
        exit
      fi

      # if any of files does not exist, run init
      if [ ! -f ~/.playground/.vscode/settings.json ] || [ ! -f ~/.playground/deno.jsonc ] || [ ! -f ~/.playground/main.ts ]
      then
        init
      fi

      cd ~/.playground

      code .
      deno task dev
    '')
  ];
}
