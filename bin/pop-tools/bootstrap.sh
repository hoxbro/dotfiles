#!/usr/bin/env bash

bootstrap() {
    mkdir -p ~/.ssh
    if [[ ! -f ~/.ssh/id_ed25519 && -f ~/Downloads/id_ed25519 ]]; then
        mv ~/Downloads/id_ed25519 ~/.ssh/id_ed25519
    fi
    chmod 600 ~/.ssh/id_ed25519

    ssh-keyscan -H github.com >>~/.ssh/known_hosts

    git clone git@github.com:hoxbro/dotfiles ~/dotfiles
}

echo -n "Bootstrapping..."
bootstrap >~/Downloads/setup0_bootstrap.log 2>&1
echo " done"
bash ~/dotfiles/bin/pop-tools/setup.sh | tee -a ~/Downloads/setup0_bootstrap.log
