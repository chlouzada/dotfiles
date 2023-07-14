{ config, pkgs, ... }:

{
  home.packages = [ pkgs.fish ];
  programs.fish = {
    enable = true;
    interactiveShellInit =
      # FZF
      ''

      '';
    shellAliases = {
      lsx = "ls -la";
    };

    functions = {
      envsource = ''
        set -l commandline (__fzf_parse_commandline)
        set -l dir $commandline[1]
        set -l fzf_query $commandline[2]
        set -l prefix $commandline[3]
        test -n "$FZF_ALT_C_COMMAND"; or set -l FZF_ALT_C_COMMAND "
        command fd . ~ -t d --max-depth 2
        test -n "$FZF_TMUX_HEIGHT"; or set FZF_TMUX_HEIGHT 40%
        begin
          set -lx FZF_DEFAULT_OPTS "--height $FZF_TMUX_HEIGHT --reverse --bind=ctrl-z:ignore $FZF_DEFAULT_OPTS $FZF_ALT_C_OPTS"
          eval "$FZF_ALT_C_COMMAND | "(__fzfcmd)' +m --query "'$fzf_query'"' | read -l result
          if [ -n "$result" ]
            cd -- $result
            # Remove last token from commandline.
            commandline -t ""
            commandline -it -- $prefix
          end
        end
        commandline -f repaint
      '';
      chtshfzf = ''
        curl --silent "cheat.sh/$(__fzf_cheat_selector)?style=rtt" | bat --style=plain
      '';
      __fzf_cheat_selector = ''
        curl --silent "cheat.sh/:list" \
            | fzf-tmux \
            -p 70%,60% \
            --layout=reverse --multi \
            --preview \
            "curl --silent cheat.sh/{}\?style=rtt" \
            --bind "?:toggle-preview" \
            --preview-window hidden,60%
      '';
    };

  };
}
