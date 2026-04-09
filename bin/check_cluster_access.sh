#!/usr/bin/env bash

set -euo pipefail

# Ensure kubectl plugins installed by this repo are discoverable.
if [[ -d "$HOME/.local/bin" ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
NAMESPACES_FILE="$REPO_ROOT/namespaces.txt"

# ========================================================================
# Pick 'nautilus' context
# ========================================================================
kubectl config get-contexts -o name | grep -qx 'nautilus' || {
    echo "Context 'nautilus' not found in kube config. Please ensure it is configured before continuing." >&2
    exit 1
}

kubectl config use-context nautilus >/dev/null

[[ -f "$NAMESPACES_FILE" ]] || {
    echo "Namespaces file not found: $NAMESPACES_FILE" >&2
    exit 1
}

# ========================================================================
# Check access to each namespace
# ========================================================================

# Read namespaces from the file, ignoring empty lines and comments.
namespaces=()
while IFS= read -r namespace || [[ -n "$namespace" ]]; do
    namespace="${namespace%$'\r'}"
    [[ "$namespace" =~ ^[[:space:]]*(#|$) ]] && continue
    namespaces+=("$namespace")
done < "$NAMESPACES_FILE"

[[ ${#namespaces[@]} -gt 0 ]] || {
    echo "No namespaces found in $NAMESPACES_FILE" >&2
    exit 1
}


any_failed=0
for namespace in "${namespaces[@]}"; do
    if kubectl get pods -n "$namespace" >/dev/null 2>&1; then
        printf '%s: [32m✔[0m\n' "$namespace"
    else
        printf '%s: [31m✗[0m\n' "$namespace"
        any_failed=1
    fi
done

exit $any_failed
