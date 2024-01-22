{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    (pkgs.writeShellScriptBin "dev" ''
      function js() {
        dependencies=$(${jq}/bin/jq -r '.dependencies + .devDependencies | keys[]' package.json)

        list=$(npm list --depth=0 -s)
        mismatch=false
        mismatched_dependencies=""
        for dependency in $dependencies; do
          if echo "$list" | grep -q "$dependency@[^ ]\+\s\+invalid" || echo $list | grep -q "UNMET DEPENDENCY $dependency@"; then
            mismatch=true
            mismatched_dependencies="$mismatched_dependencies $dependency"
          fi
        done
        if [ "$mismatch" = true ]; then
          # prompt Y/n
          echo "There are mismatches between package.json and installed packages."
          echo $mismatched_dependencies
          echo "Would you like to install? (Y/n)"
          read -r answer 

          if [ "$answer" = "n" ]; then
            code . &> /dev/null
            exit 0
          fi

          code . &> /dev/null

          echo "Installing missing packages..."
          npm install

          echo "Starting..."
          npm run dev
        else
          code . &> /dev/null

          echo "Starting..."
          npm run dev
        fi
      }

      if [ -f package.json ]; then
        js
      else
        code . &> /dev/null
      fi
    '')
  ];
}
