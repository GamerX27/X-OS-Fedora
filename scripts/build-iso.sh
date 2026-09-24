#!/usr/bin/env bash
set -euo pipefail

REGISTRY="ghcr.io/gamerx27"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="${REPO_ROOT}/iso-out"
MIN_FREE_GB=20
INSTALLER_IMAGE="ghcr.io/jasonn3/build-container-installer:v1.5.0"

usage() {
  echo "Usage: $0 [base|lts|gaming|media-pc]"
  echo "  base      x27-linux (default)"
  echo "  lts       x27-linux-lts"
  echo "  gaming    x27-linux-gaming"
  echo "  media-pc  x27-linux-media-pc"
}

TARGET=""
for arg in "$@"; do
  case "$arg" in
    -h|--help)
      usage
      exit 0
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
TARGET="${TARGET:-base}"

case "$TARGET" in
  base)     IMAGE="x27-linux" ;;
  lts)      IMAGE="x27-linux-lts" ;;
  gaming)   IMAGE="x27-linux-gaming" ;;
  media-pc) IMAGE="x27-linux-media-pc" ;;
  *)
    echo "Unknown target: $TARGET" >&2
    usage >&2
    exit 1
    ;;
esac

ISO_NAME="${IMAGE}.iso"
IMAGE_REF="${REGISTRY}/${IMAGE}:latest"

if ! command -v docker >/dev/null 2>&1; then
  echo "docker not found on PATH." >&2
  exit 1
fi

mkdir -p "$OUT_DIR"

AVAIL_GB=$(( $(df --output=avail -k "$OUT_DIR" | tail -n1) / 1024 / 1024 ))
if [ "$AVAIL_GB" -lt "$MIN_FREE_GB" ]; then
  echo "WARNING: only ${AVAIL_GB}GB free at ${OUT_DIR}, ${MIN_FREE_GB}GB+ recommended."
fi

# Not `bluebuild generate-iso`: BlueBuild CLI (v0.9.37) pins build-container-installer v1.4.0,
# whose lorax templates strip /usr/sbin/load_policy. Anaconda 44.30 runs it on exit, crashes,
# and hangs at the end-of-install Reboot button. v1.5.0 keeps it. Same args BlueBuild passed.
echo "Building ${ISO_NAME} from ${IMAGE_REF}"
rm -f "${OUT_DIR}/${ISO_NAME}" "${OUT_DIR}/${ISO_NAME}-CHECKSUM"
sudo docker run --rm --privileged \
  -v "${OUT_DIR}:/build-container-installer/build" \
  -v dnf-cache:/cache/dnf/ \
  "${INSTALLER_IMAGE}" \
  VARIANT=kinoite \
  "ISO_NAME=build/${ISO_NAME}" \
  DNF_CACHE=/cache/dnf \
  SECURE_BOOT_KEY_URL=https://github.com/ublue-os/bazzite/raw/main/secure_boot.der \
  ENROLLMENT_PASSWORD=universalblue \
  WEB_UI=false \
  "IMAGE_NAME=${IMAGE}" \
  "IMAGE_REPO=${REGISTRY}" \
  IMAGE_TAG=latest \
  VERSION=44
cd "$OUT_DIR"
sudo chown "$(id -un):$(id -gn)" "$ISO_NAME"

echo "Generating checksum"
sha256sum "$ISO_NAME" > "${ISO_NAME}.sha256sum"

echo "Done: ${OUT_DIR}/${ISO_NAME}"
echo "      ${OUT_DIR}/${ISO_NAME}.sha256sum"
