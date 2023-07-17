{ config, pkgs, ... }:

{
  home.packages = [ pkgs.fish ];
  programs.fish = {
    enable = true;
    interactiveShellInit =
      ## fzf
      ''
        bind \e\cf _fzf_search_dir
        bind \e\cs _fzf_search_git_status
      '';
    
    shellAliases = {
      # sl = "ls -la";
    };

    shellAbbrs = {
      ls = "ls -la";
      hms = "home-manager switch";
    };

    functions = {
      _fzf_report_diff_type = {
        argumentNames = "diff_type";
        body = ''
          set -f repeat_count (math 2 + (string length $diff_type))
          set -f line (string repeat --count $repeat_count ─)
          # set -f top_border ╭$line╮
          # set -f btm_border ╰$line╯

          # TODO: color according to diff_type
          set_color yellow
          echo $top_border
          # echo "│ $diff_type │"
          echo "$diff_type"
          echo $btm_border
          set_color normal
        '';
      };

      _fzf_preview_changed_file = {
        argumentNames = "path_status";
        body = ''
          set -f path (string unescape (string sub --start 4 $path_status))
          set -f index_status (string sub --length 1 $path_status)
          set -f working_tree_status (string sub --start 2 --length 1 $path_status)

          set -f diff_opts --color=always

          if test $index_status = '?'
              _fzf_report_diff_type Untracked
              _fzf_preview_file $path
          else if contains {$index_status}$working_tree_status DD AU UD UA DU AA UU
              _fzf_report_diff_type Unmerged
              git diff $diff_opts -- $path
          else
              if test $index_status != " "
                  _fzf_report_diff_type Staged

                  if test $index_status = R
                      set -f orig_and_new_path (string split --max 1 -- ' -> ' $path)
                      git diff --staged $diff_opts -- $orig_and_new_path[1] $orig_and_new_path[2]
                      set path $orig_and_new_path[2]
                  else
                      git diff --staged $diff_opts -- $path
                  end
              end

              if test $working_tree_status != ' '
                  _fzf_report_diff_type Unstaged
                  git diff $diff_opts -- $path
              end
          end
        '';
      };

      _fzf_search_git_status = ''
        if not git rev-parse --git-dir >/dev/null 2>&1
          echo '_fzf_search_git_status: Not in a git repository.' >&2
        else
            set -f selected_paths (
                git -c color.status=always status --short |
                _fzf_wrapper --ansi \
                    --multi \
                    --prompt="Search Git Status> " \
                    --query=(commandline --current-token) \
                    --preview='_fzf_preview_changed_file {}' \
                    --nth="2.." \
                    $fzf_git_status_opts
            )
            if test $status -eq 0
                set -f cleaned_paths

                for path in $selected_paths
                    if test (string sub --length 1 $path) = R
                        set --append cleaned_paths (string split -- "-> " $path)[-1]
                    else
                        set --append cleaned_paths (string sub --start=4 $path)
                    end
                end

                commandline --current-token --replace -- (string join ' ' $cleaned_paths)
            end
        end

        commandline --function repaint
      '';

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

        if test -L "$file_path"
            set -l target_path (realpath "$file_path")

            set_color yellow
            echo "'$file_path' is a symlink to '$target_path'."
            set_color normal

            _fzf_preview_file "$target_path"
        else if test -f "$file_path"
            if set --query fzf_preview_file_cmd
                eval "$fzf_preview_file_cmd '$file_path'"
            else
                bat --style=numbers --color=always "$file_path"
            end
        else if test -d "$file_path"
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

      _node_installer = ''
        set -f is_installed (command -v node)

        if test -z $is_installed
          echo "node not installed, installing now..."
          sudo pacman -S nodejs npm --noconfirm
        else
          echo "node already installed"
        end
      '';

      _node_uninstaller = ''
        set -f is_installed (command -v node)

        if test -z $is_installed
          echo "node not installed"
        else
          echo "uninstalling nodejs now..."
          sudo pacman -R nodejs npm --noconfirm
        end
      '';
    };

  };
}
