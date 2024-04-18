{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    (pkgs.writeShellScriptBin "asdfx" ''
      selected_plugin=$(${asdf-vm}/bin/asdf plugin-list-all | awk '{print $1}' | ${pkgs.fzf}/bin/fzf)

      if ! ${asdf-vm}/bin/asdf plugin-list | grep -q "$selected_plugin"; then
        ${asdf-vm}/bin/asdf plugin-add "$selected_plugin"
      fi

      selected_version=$(${asdf-vm}/bin/asdf list-all "$selected_plugin" | awk '{print $1}' | tac | ${pkgs.fzf}/bin/fzf)
  
      if ! ${asdf-vm}/bin/asdf list "$selected_plugin" | grep -q "$selected_version"; then
        ${asdf-vm}/bin/asdf install "$selected_plugin" "$selected_version"
      fi

      ${asdf-vm}/bin/asdf global "$selected_plugin" "$selected_version"
    '')
  ];
}
