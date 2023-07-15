{ config, pkgs, ... }:

{
  home.packages = [ pkgs.fish ];
  programs.fish = {
    enable = true;
    interactiveShellInit =
      # FZF
      ''
        bind \ee _fzf_search_dir
        bind \e\cf _fzf_search_dir
      '';
    shellAliases = {
      sl = "ls -la";
    };
    shellAbbrs = {
      # nix
      hms = "home-manager switch";
    };
    functions = {
      _fzf_search_dir = ''
        set -f fd_cmd (command -v fdfind || command -v fd  || echo "fd")
        set -f --append fd_cmd --color=always $fzf_fd_opts

        set -f fzf_arguments --multi --ansi $fzf_dir_opts $fzf_directory_opts
        set -f token (commandline --current-token)
        set -f expanded_token (eval echo -- $token)
        set -f unescaped_exp_token (string unescape -- $expanded_token)

        if string match --quiet -- "*/" $unescaped_exp_token && test -d "$unescaped_exp_token"
            set --append fd_cmd --base-directory=$unescaped_exp_token
            set --prepend fzf_arguments --prompt="Search Directory $unescaped_exp_token> " --preview="_fzf_preview_file $expanded_token{}"
            set -f file_paths_selected $unescaped_exp_token($fd_cmd 2>/dev/null | _fzf_wrapper $fzf_arguments)
        else
            set --prepend fzf_arguments --prompt="Search Directory> " --query="$unescaped_exp_token" --preview='_fzf_preview_file {}'
            set -f file_paths_selected ($fd_cmd 2>/dev/null | _fzf_wrapper $fzf_arguments)
        end


        if test $status -eq 0
            commandline --current-token --replace -- (string escape -- $file_paths_selected | string join ' ')
        end

        commandline --function repaint
      '';
      _fzf_wrapper = ''
        set -f --export SHELL (command --search fish)

        if not set --query FZF_DEFAULT_OPTS
            set --export FZF_DEFAULT_OPTS '--cycle --layout=reverse --border --height=90% --preview-window=wrap --marker="*"'
        end

        fzf $argv
        '';
      _fzf_preview_file = ''
        set -f file_path $argv

        set -l target_path (realpath "$file_path")

        set_color yellow
        echo "'$file_path' is a symlink to '$target_path'."
        set_color normal

        _fzf_preview_file "$target_path"
        if set --query fzf_preview_file_cmd
            eval "$fzf_preview_file_cmd '$file_path'"
        else
            bat --style=numbers --color=always "$file_path"
        end
        if set --query fzf_preview_dir_cmd
            eval "$fzf_preview_dir_cmd '$file_path'"
        else
            command ls -A -F "$file_path"
        end
        else if test -c "$file_path"
            _fzf_report_file_type "$file_path" "character device file"
        else if test -b "$file_path"
            _fzf_report_file_type "$file_path" "block device file"
        else if test -S "$file_path"
            _fzf_report_file_type "$file_path" socket
        else if test -p "$file_path"
            _fzf_report_file_type "$file_path" "named pipe"
        else
            echo "$file_path doesn't exist." >&2
        end
      '';
    };

  };
}
