if status is-interactive
#
    set -g fish_greeting

    set -Ux ANDROID_HOME $HOME/Android/Sdk
    fish_add_path $ANDROID_HOME/emulator
    fish_add_path $ANDROID_HOME/platform-tools

    alias s="cd .."
    alias fd="fdfind"
    alias c="editor ."

    abbr -a lg lazygit
    abbr -a ldock lazydocker
    # abbr -a c "code ."
    # abbr -a c "codium ."
    abbr -a d "npm run dev"
    abbr -a gsub "git submodule update --init --recursive"

    ~/.local/bin/mise activate fish | source

    bind \e\cf _fzf_search_dir
    function _fzf_search_dir
        set dir (fd . ~ --type d --max-depth 2 | fzf)

        if test -n "$dir"
            cd "$dir"
            commandline -f repaint
        end
    end

    function editor
        if command -q codium
            codium $argv
        else if command -q code
            code $argv
        else
            return 1
        end
    end

#
end