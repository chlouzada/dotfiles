{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    jq

    (pkgs.writeShellScriptBin "dev" ''
      function js() {
        dependencies=$(jq -r '.dependencies + .devDependencies | keys[]' package.json)

        list=$(npm list --depth=0 -s)
        mismatch=false
        for dependency in $dependencies; do
          if echo "$list" | grep -q "$dependency@[^ ]\+\s\+invalid" || echo $list | grep -q "UNMET DEPENDENCY $dependency@"; then
            mismatch=true
          fi
        done
        if [ "$mismatch" = true ]; then
          # prompt Y/n
          echo "There are mismatches between package.json and installed packages."
          echo "Would you like to install the missing packages? (Y/n)"
          read -r answer 

          if [ "$answer" = "n" ]; then
            code . &> /dev/null
            exit 0
          fi

          echo "Installing missing packages..."
          npm install
        fi

        code . &> /dev/null

        echo "Starting..."
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