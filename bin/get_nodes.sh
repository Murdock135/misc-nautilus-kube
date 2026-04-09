#!/usr/bin/env bash

# Ensure kubectl plugins installed by this repo are discoverable.
if [[ -d "$HOME/.local/bin" ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# [Note: This command will launch your browser for authentication if you are not already logged in.]
kubectl get nodes