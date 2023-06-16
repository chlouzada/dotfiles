export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# FNM - Node Version Manager
export PATH="/home/ch/.local/share/fnm:$PATH"
eval "`fnm env`"

# DENO
export DENO_INSTALL="/home/ch/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"


# FZF
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Modified fzf cd widget to ignore folders from .ignore file
# REQUIRED: fd, tree
# SETUP: .ignore file in home folder
# find $HOME -maxdepth 1 -type d | sed 's/\/home\/ch\///g' | sed 's/\/home\/ch//g' > $HOME/.ignore
fzf-cd-widget() {
  local cmd="${FZF_ALT_C_COMMAND:-"command fd . ~ -t d --max-depth 2"}"
  setopt localoptions pipefail no_aliases 2> /dev/null
  local dir="$(eval "$cmd" | FZF_DEFAULT_OPTS="--preview 'tree -L 1 -C {} | head -200' --preview-window=right:50%:wrap --height ${FZF_TMUX_HEIGHT:-40%} --reverse --bind=ctrl-z:ignore ${FZF_DEFAULT_OPTS-} ${FZF_ALT_C_OPTS-}" $(__fzfcmd) +m)"
  if [[ -z "$dir" ]]; then
    zle redisplay
    return 0
  fi
  zle push-line
  BUFFER="cd ${(q)dir}"
  zle accept-line
  local ret=$?
  unset dir
  zle reset-prompt
  return $ret
}


# regain focus when opening vscode on current folder
# REQUIRED: xdotool and x11
rf-vscode() {
  # if not args 
  if [ $# -eq 0 ]; then
    local terminal_id=$(xdotool getactivewindow)
    code .
    while [[ $(xdotool getactivewindow) == $terminal_id ]]; do
      sleep 0.001
    done
    xdotool windowactivate $terminal_id
    return
  fi
  # else 
  local terminal_id=$(xdotool getactivewindow)
  code "$@"
  while [[ $(xdotool getactivewindow) == $terminal_id ]]; do
    sleep 0.001
  done
  xdotool windowactivate $terminal_id

}

# MongoDB docker container
# REQUIRED: docker
mongodb() {
  if [ -z "$(sudo docker ps -aq -f name=mongodb)" ]; then
    echo "Creating MongoDB and starting it detached"
    sudo docker run --name mongodb -d -p 27017:27017 mongo 
    return
  fi

  if [ -z "$(sudo docker ps -aq -f name=mongodb -f status=running)" ]; then
    echo "MongoDB is already created"
    echo "Starting MongoDB"
    sudo docker start mongodb
    return
  fi

  echo "MongoDB is already running: mongodb://admin:admin@localhost:27017"
}

alias c="rf-vscode"


# NODE
NPM_PACKAGES="${HOME}/.npm-packages"
export PATH="$PATH:$NPM_PACKAGES/bin"
export MANPATH="${MANPATH-$(manpath)}:$NPM_PACKAGES/share/man"
alias d="npm run dev"
alias i="npm install"


demo() {
  c ~/repositories/demo
  deno run --allow-net --allow-read --allow-write --allow-env --allow-run --unstable --watch ~/repositories/demo/src/index.ts
}