#!/usr/bin/env bash

set -euo pipefail

# ========================================================================
# Constants
# ========================================================================
KUBE_DIR="$HOME/.kube"
CONFIG_PATH="$KUBE_DIR/config"
CONFIG_URL="https://nrp.ai/config"

# =========================================================================
# Helpers
# =========================================================================
apply_wsl_browser_command() {
    local browser_command tmp_config

    browser_command="$(pick_wsl_browser_command)"
    tmp_config="$(mktemp)"

    if ! awk -v browser_command="$browser_command" '
        BEGIN {
            inserted = 0
            replaced = 0
        }
        /^      - --browser-command=/ {
            print "      - " browser_command
            inserted = 1
            replaced = 1
            next
        }
        /^      - --listen-address=/ && !inserted {
            print
            print "      - " browser_command
            inserted = 1
            next
        }
        { print }
        END {
            if (!inserted) {
                exit 1
            }
        }
    ' "$CONFIG_PATH" > "$tmp_config"; then
        rm -f "$tmp_config"
        echo "Could not find where to insert the WSL browser command in $CONFIG_PATH" >&2
        exit 1
    fi

    mv "$tmp_config" "$CONFIG_PATH"
    chmod 600 "$CONFIG_PATH"
    echo "Set WSL browser command to $browser_command"
}

pick_wsl_browser_command() {
    local browser_choice browser_path

    read -r -p "Browser for kubelogin [chrome/firefox] (chrome): " browser_choice
    browser_choice="${browser_choice:-chrome}"
    browser_choice="$(printf '%s' "$browser_choice" | tr '[:upper:]' '[:lower:]')"

    case "$browser_choice" in
        chrome)
            browser_path="/mnt/c/Program Files/Google/Chrome/Application/chrome.exe"
            ;;
        firefox)
            browser_path="/mnt/c/Program Files/Mozilla Firefox/firefox.exe"
            ;;
        *)
            echo "Unsupported browser choice: $browser_choice" >&2
            return 1
            ;;
    esac

    if [[ ! -f "$browser_path" ]]; then
        echo "Browser executable not found: $browser_path" >&2
        return 1
    fi

    printf '%s' "--browser-command=$browser_path"
}

is_wsl() {
    grep -qiE '(microsoft|wsl)' /proc/version 2>/dev/null || \
        grep -qiE '(microsoft|wsl)' /proc/sys/kernel/osrelease 2>/dev/null
}

# =========================================================================
# Download kube config
# =========================================================================
mkdir -p "$KUBE_DIR"
curl -fL "$CONFIG_URL" -o "$CONFIG_PATH"
chmod 600 "$CONFIG_PATH"

echo "Downloaded kube config to $CONFIG_PATH"

# If running in WSL, set the kubelogin browser command to launch the Windows browser.
if is_wsl; then
    apply_wsl_browser_command
fi
