{ config, pkgs, ... }:

{
  programs.fzf = {
    enable = true;
  };

  home.packages = with pkgs; [
    asdf-vm

    (pkgs.writeShellScriptBin "asdfx" ''
      #!/bin/bash

      selected_plugin=$(asdf plugin-list-all | awk '{print $1}' | fzf)

      if ! asdf plugin-list | grep -q "$selected_plugin"; then
        asdf plugin-add "$selected_plugin"
      fi

      selected_version=$(asdf list-all "$selected_plugin" | awk '{print $1}' | tac | fzf)
  
      if ! asdf list "$selected_plugin" | grep -q "$selected_version"; then
        asdf install "$selected_plugin" "$selected_version"
      fi

      asdf global "$selected_plugin" "$selected_version"
    '')
  ];
}
