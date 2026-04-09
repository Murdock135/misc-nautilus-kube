#!/usr/bin/env bash

set -euo pipefail

# Fail early if any required tool is missing.
for command in curl jq unzip sha256sum; do
	command -v "$command" >/dev/null 2>&1 || {
		echo "Missing required command: $command" >&2
		exit 1
	}
done

# Detect the current platform and let the user override it if needed.
DETECTED_OS_NAME="$(uname -s | tr '[:upper:]' '[:lower:]')"

case "$(uname -m)" in
	x86_64)
		DETECTED_OS_ARCHITECTURE="amd64"
		;;
	aarch64|arm64)
		DETECTED_OS_ARCHITECTURE="arm64"
		;;
	armv7l|armv6l)
		DETECTED_OS_ARCHITECTURE="arm"
		;;
	ppc64le)
		DETECTED_OS_ARCHITECTURE="ppc64le"
		;;
	*)
		echo "Unsupported architecture: $(uname -m)" >&2
		exit 1
		;;
esac

read -r -p "OS name [${DETECTED_OS_NAME}]: " OS_NAME_INPUT
OS_NAME="${OS_NAME_INPUT:-$DETECTED_OS_NAME}"

read -r -p "OS architecture [${DETECTED_OS_ARCHITECTURE}]: " OS_ARCHITECTURE_INPUT
OS_ARCHITECTURE="${OS_ARCHITECTURE_INPUT:-$DETECTED_OS_ARCHITECTURE}"

INSTALL_DIR="$HOME/.local/bin"
INSTALL_PATH="$INSTALL_DIR/kubectl-oidc_login"
ARCHIVE_NAME="kubelogin_${OS_NAME}_${OS_ARCHITECTURE}.zip"
CHECKSUM_NAME="${ARCHIVE_NAME}.sha256"

KUBELOGIN_VERSION="$(curl -fsSL "https://api.github.com/repos/int128/kubelogin/releases/latest" | jq -r '.tag_name')"

# Download into a temporary directory so partial files do not pollute the workspace.
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

ARCHIVE_PATH="$TMP_DIR/$ARCHIVE_NAME"
CHECKSUM_PATH="$TMP_DIR/$CHECKSUM_NAME"

curl -fL -o "$ARCHIVE_PATH" "https://github.com/int128/kubelogin/releases/download/${KUBELOGIN_VERSION}/${ARCHIVE_NAME}"
curl -fL -o "$CHECKSUM_PATH" "https://github.com/int128/kubelogin/releases/download/${KUBELOGIN_VERSION}/${CHECKSUM_NAME}"

# The upstream checksum file already includes the archive name.
(
	cd "$TMP_DIR"
	sha256sum --check "$CHECKSUM_NAME"
)

# Find the kubelogin binary even if the zip layout changes to include subdirectories.
ARCHIVE_ENTRY="$(unzip -Z1 "$ARCHIVE_PATH" | awk '/(^|\/)kubelogin$/ { print; exit }')"

if [[ -z "$ARCHIVE_ENTRY" ]]; then
	echo "Could not find kubelogin in archive: $ARCHIVE_NAME" >&2
	exit 1
fi

# Install as the kubectl plugin name expected by kubectl oidc-login integrations.
if [[ -d "$INSTALL_PATH" ]]; then
	echo "Install target already exists as a directory: $INSTALL_PATH" >&2
	echo "Remove or rename that directory, then run the script again." >&2
	exit 1
fi

mkdir -p "$INSTALL_DIR"
unzip -p "$ARCHIVE_PATH" "$ARCHIVE_ENTRY" > "$TMP_DIR/kubelogin"
install -m 0755 "$TMP_DIR/kubelogin" "$INSTALL_PATH"

"$INSTALL_PATH" --version
