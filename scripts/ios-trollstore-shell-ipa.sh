#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  scripts/ios-trollstore-shell-ipa.sh [--out /tmp/OpenClaw-trollstore-shell.ipa] [--build-number 123]

Builds an unsigned TrollStore shell IPA on macOS.
This script is intended for personal TrollStore installs.
EOF
}

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IOS_DIR="${ROOT_DIR}/apps/ios"
WORK_DIR="${IOS_DIR}/build/trollstore-shell"
DERIVED_DATA_DIR="${WORK_DIR}/DerivedData"
OUT_IPA="${WORK_DIR}/OpenClaw-trollstore-shell.ipa"
BUILD_NUMBER=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --)
      shift
      ;;
    --out)
      OUT_IPA="${2:-}"
      shift 2
      ;;
    --build-number)
      BUILD_NUMBER="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This script must run on macOS (xcodebuild required)." >&2
  exit 1
fi

if ! command -v xcodegen >/dev/null 2>&1; then
  echo "Missing dependency: xcodegen" >&2
  exit 1
fi

if ! command -v xcodebuild >/dev/null 2>&1; then
  echo "Missing dependency: xcodebuild (install Xcode Command Line Tools)." >&2
  exit 1
fi

if ! command -v zip >/dev/null 2>&1; then
  echo "Missing dependency: zip" >&2
  exit 1
fi

if [[ -n "${BUILD_NUMBER}" ]]; then
  "${ROOT_DIR}/scripts/ios-write-version-xcconfig.sh" --build-number "${BUILD_NUMBER}"
else
  "${ROOT_DIR}/scripts/ios-write-version-xcconfig.sh"
fi

mkdir -p "${WORK_DIR}"
rm -rf "${DERIVED_DATA_DIR}" "${WORK_DIR}/Payload"

(
  cd "${IOS_DIR}"
  xcodegen generate --spec project.trollstore-shell.yml
  xcodebuild \
    -project OpenClaw.xcodeproj \
    -scheme OpenClaw \
    -configuration Release \
    -sdk iphoneos \
    -derivedDataPath "${DERIVED_DATA_DIR}" \
    CODE_SIGNING_ALLOWED=NO \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGN_IDENTITY="" \
    build
)

APP_PATH="${DERIVED_DATA_DIR}/Build/Products/Release-iphoneos/OpenClaw.app"
if [[ ! -d "${APP_PATH}" ]]; then
  echo "Build succeeded but app bundle not found: ${APP_PATH}" >&2
  exit 1
fi

mkdir -p "${WORK_DIR}/Payload"
cp -R "${APP_PATH}" "${WORK_DIR}/Payload/OpenClaw.app"

rm -f "${OUT_IPA}"
(
  cd "${WORK_DIR}"
  zip -qry "${OUT_IPA}" Payload
)

echo "Built TrollStore shell IPA: ${OUT_IPA}"
