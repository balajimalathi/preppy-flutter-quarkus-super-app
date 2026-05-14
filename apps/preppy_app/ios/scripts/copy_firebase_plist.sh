#!/bin/sh
# Copies the flavor-specific GoogleService-Info.plist into the built iOS app bundle.
# Plists are generated under ios/Firebase/<flavor>/ by configure_firebase_envs.sh.
set -e

case "${CONFIGURATION}" in
  *-dev) FLAVOR=dev ;;
  *-staging) FLAVOR=staging ;;
  *-prod) FLAVOR=prod ;;
  Debug|Release|Profile) FLAVOR=prod ;;
  *)
    echo "warning: Unknown CONFIGURATION=${CONFIGURATION}; using prod Firebase plist." >&2
    FLAVOR=prod
    ;;
esac

SRC="${SRCROOT}/Firebase/${FLAVOR}/GoogleService-Info.plist"
DEST="${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist"

if [ ! -f "${SRC}" ]; then
  echo "error: Missing ${SRC}. Run scripts/configure_firebase_envs.sh from apps/preppy_app for flavor '${FLAVOR}'." >&2
  exit 1
fi

mkdir -p "$(dirname "${DEST}")"
cp -f "${SRC}" "${DEST}"
