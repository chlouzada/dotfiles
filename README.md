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
#!/bin/sh

# Install Home Manager
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install

# Download dotfiles tar and extract contents
curl -L https://github.com/chlouzada/dotfiles/archive/refs/tags/latest.tar.gz | tar -xz -C $HOME

# Move files to correct locations
rm -rf $HOME/.config/home-manager
mv $HOME/dotfiles-latest/home-manager/.config/home-manager $HOME/.config/home-manager

# Load Home Manager
home-manager switch -b backup

# Replace dotfiles-latest with dotfiles
rm -rf $HOME/dotfiles-latest
git clone https://github.com/chlouzada/dotfiles.git $HOME/dotfiles

# Stow home-manager
rm -rf $HOME/.config/home-manager
stow -t $HOME -d $HOME/dotfiles -S home-manager
```