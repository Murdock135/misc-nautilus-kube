#!/usr/bin/env bash

set -euo pipefail

# Ensure kubectl plugins installed by this repo are discoverable.
if [[ -d "$HOME/.local/bin" ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

kubectl config get-contexts -o name | grep -qx 'nautilus' || {
    echo "Context 'nautilus' not found in kube config. Please ensure it is configured before continuing." >&2
    exit 1
}

kubectl config use-context nautilus >/dev/null