#!/usr/bin/env bash
set -euo pipefail

REGISTRY="ghcr.io/gamerx27"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="${REPO_ROOT}/iso-out"
MIN_FREE_GB=20

usage() {
  echo "Usage: $0 [-y|--yes] [fedora|lts|gaming|media-pc]"
  echo "  fedora    x-os-fedora (default)"
  echo "  lts       x-os-fedora-lts"
  echo "  gaming    x-os-gaming"
  echo "  media-pc  x-os-media-pc"
  echo "  -y, --yes  don't ask before installing the BlueBuild CLI"
}

ASSUME_YES=0
TARGET=""
for arg in "$@"; do
  case "$arg" in
    -h|--help)
      usage
      exit 0
      ;;
    -y|--yes)
      ASSUME_YES=1
      ;;
    *)
      if [ -n "$TARGET" ]; then
        echo "Unexpected extra argument: $arg" >&2
        usage >&2
        exit 1
      fi
      TARGET="$arg"
      ;;
  esac
done
TARGET="${TARGET:-fedora}"

case "$TARGET" in
  fedora)   IMAGE="x-os-fedora" ;;
  lts)      IMAGE="x-os-fedora-lts" ;;
  gaming)   IMAGE="x-os-gaming" ;;
  media-pc) IMAGE="x-os-media-pc" ;;
  *)
    echo "Unknown target: $TARGET" >&2
    usage >&2
    exit 1
    ;;
esac

ISO_NAME="${IMAGE}.iso"
IMAGE_REF="${REGISTRY}/${IMAGE}:latest"

if ! command -v bluebuild >/dev/null 2>&1; then
  echo "bluebuild CLI not found on PATH."
  echo "Install command (downloads and runs a script from GitHub as your user):"
  echo "  bash <(curl -s https://raw.githubusercontent.com/blue-build/cli/main/install.sh)"
  if [ "$ASSUME_YES" -ne 1 ]; then
    read -r -p "Run this now? [y/N] " REPLY
  else
    REPLY="y"
  fi
  case "$REPLY" in
    [yY]|[yY][eE][sS])
      bash <(curl -s https://raw.githubusercontent.com/blue-build/cli/main/install.sh)
      ;;
    *)
      echo "Aborting. Install bluebuild manually, then re-run this script." >&2
      exit 1
      ;;
  esac
  command -v bluebuild >/dev/null 2>&1 \
    || { echo "bluebuild still not on PATH. Check your PATH and re-run." >&2; exit 1; }
fi

mkdir -p "$OUT_DIR"

AVAIL_GB=$(( $(df --output=avail -k "$OUT_DIR" | tail -n1) / 1024 / 1024 ))
if [ "$AVAIL_GB" -lt "$MIN_FREE_GB" ]; then
  echo "WARNING: only ${AVAIL_GB}GB free at ${OUT_DIR}, ${MIN_FREE_GB}GB+ recommended."
fi

echo "Building ${ISO_NAME} from ${IMAGE_REF}"
cd "$OUT_DIR"
sudo bluebuild generate-iso --iso-name "$ISO_NAME" image "$IMAGE_REF"
sudo chown "$(id -un):$(id -gn)" "$ISO_NAME"

echo "Generating checksum"
sha256sum "$ISO_NAME" > "${ISO_NAME}.sha256sum"

echo "Done: ${OUT_DIR}/${ISO_NAME}"
echo "      ${OUT_DIR}/${ISO_NAME}.sha256sum"
