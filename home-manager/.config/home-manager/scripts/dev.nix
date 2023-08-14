{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    jq

    (pkgs.writeShellScriptBin "dev" ''
      function js() {
        code . &> /dev/null

        dependencies=$(jq -r '.dependencies + .devDependencies | keys[]' package.json)

        list=$(npm list --depth=0 -s)
        mismatch=false
        for dependency in $dependencies; do
          if echo "$list" | grep -q "$dependency@[^ ]\+\s\+invalid" || echo $list | grep -q "UNMET DEPENDENCY $dependency@"; then
            mismatch=true
          fi
        done
        if [ "$mismatch" = true ]; then
          echo "There are mismatches between package.json and installed packages."
          npm install
        fi

        npm run dev
      }

      if [ -f package.json ]; then
        js
      else
        code . &> /dev/null
      fi
    '')
  ];
}
