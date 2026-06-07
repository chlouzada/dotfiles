if status is-interactive
    set -g fish_greeting

    set -Ux ANDROID_HOME $HOME/Android/Sdk
    fish_add_path $ANDROID_HOME/emulator
    fish_add_path $ANDROID_HOME/platform-tools

    alias s="cd .."

    alias fd="fdfind"

    abbr -a lg lazygit
    abbr -a ldocker lazydocker
    abbr -a c "code ."

    ~/.local/bin/mise activate fish | source

    bind \e\cf _fzf_search_dir
    function _fzf_search_dir
        set dir (fd . ~ --type d --max-depth 1 | fzf)

        if test -n "$dir"
            cd "$dir"
            commandline -f repaint
        end
    end
end