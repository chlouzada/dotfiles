# Dotfiles

## Stow Dotfiles

### Requirements

- Stow

```
stow home-manager nvim -t ~
```

## Home Manager Install Script

### Requirements

- Nix

### Script

```
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install

curl -L https://github.com/chlouzada/dotfiles/archive/refs/tags/latest.tar.gz | tar -xz -C $HOME

rm -rf $HOME/.config/home-manager
mv $HOME/dotfiles-latest/home-manager/.config/home-manager $HOME/.config/home-manager

home-manager switch -b backup

rm -rf $HOME/dotfiles-latest
git clone https://github.com/chlouzada/dotfiles.git $HOME/dotfiles

rm -rf $HOME/.config/home-manager
stow -t $HOME -d $HOME/dotfiles -S home-manager
```
