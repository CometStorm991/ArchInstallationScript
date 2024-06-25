#!/bin/bash

rm $HOME/.wget-hsts
rm $HOME/.lesshst
rm $HOME/.bash_history
rm $HOME/.history
rm $HOME/.nmcli-history
rm $HOME/.node_repl_history
rm $HOME/.python_history
rm -rf $HOME/.local/share/Trash/*
rm -rf $HOME/.config/.local/share/Trash/*
history -c
if test -n "$BASH_VERSION"
then
    history -w
fi
sudo pacman -Scc --noconfirm
