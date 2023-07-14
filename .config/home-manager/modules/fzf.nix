{ config, pkgs, ... }:

{
  home.packages = [ pkgs.fzf ];
  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };
  programs.fish = {
    shellAliases = {
      lsx = "ls -la";
    };
    functions = {
      testi = ''
        set -l cmd (command fd . ~ -t d --max-depth 2)
        set -l prev_pipefail $pipestatus[1]
        set -e pipefail no_aliases 2> /dev/null
        set -l dir (eval $cmd | env FZF_DEFAULT_OPTS="--preview 'tree -L 1 -C {} | head -200' --preview-window=right:50%:wrap --height $FZF_TMUX_HEIGHT --reverse --bind=ctrl-z:ignore $FZF_DEFAULT_OPTS $FZF_ALT_C_OPTS" (__fzfcmd) +m)
        if test -z "$dir"
          zle redisplay
          return 0
        end
        zle push-line
        set -l escaped_dir (printf "%q" $dir)
        set -l buffer "cd $escaped_dir"
        set -l ret $status
        zle accept-line
        unset -l dir
        zle reset-prompt
        return $ret
      '';
    };
  };
}
