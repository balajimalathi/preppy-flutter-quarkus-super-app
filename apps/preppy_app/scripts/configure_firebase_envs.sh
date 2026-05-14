#!/usr/bin/env bash
#
# Interactive multi-environment Firebase setup using FlutterFire CLI.
#
# Prerequisites:
#   - Flutter SDK and Dart on PATH
#   - Firebase CLI logged in: https://firebase.google.com/docs/cli#install-cli
#   - Python 3 on PATH (parses `firebase projects:list --json` for the numbered list)
#   - Run from the preppy_app package root (apps/preppy_app), or pass --project-dir
#
# Prod Android applicationId is usually the base package (e.g. com.example.app); other
# flavors often use suffixes (.dev, .staging) matching android/app/build.gradle.kts.
#
# Usage:
#   ./scripts/configure_firebase_envs.sh
#   ./scripts/configure_firebase_envs.sh --project-dir /path/to/preppy_app
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
FB_LIST_TMP=""

usage() {
  echo "Usage: $0 [--project-dir <path_to_preppy_app>]" >&2
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project-dir)
      APP_ROOT="$(cd "$2" && pwd)"
      shift 2
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 1
      ;;
  esac
done

cleanup_fb_list() {
  if [[ -n "${FB_LIST_TMP}" && -f "${FB_LIST_TMP}" ]]; then
    rm -f "${FB_LIST_TMP}"
  fi
}
trap cleanup_fb_list EXIT

cd "${APP_ROOT}"

if [[ ! -f pubspec.yaml ]]; then
  echo "error: No pubspec.yaml in ${APP_ROOT}. Use --project-dir or run from apps/preppy_app." >&2
  exit 1
fi

require_firebase_cli() {
  if ! command -v firebase >/dev/null 2>&1; then
    echo "error: Firebase CLI not found. Install: https://firebase.google.com/docs/cli#install-cli" >&2
    exit 1
  fi
  if ! command -v python3 >/dev/null 2>&1; then
    echo "error: python3 not found (needed to list Firebase projects). Install Python 3." >&2
    exit 1
  fi
}

# Writes TSV lines: index<TAB>projectId<TAB>displayName into FB_LIST_TMP.
fetch_firebase_projects_tsv() {
  FB_LIST_TMP="$(mktemp)"
  if ! firebase projects:list --json 2>/dev/null |
    python3 -c '
import json, sys
try:
    data = json.load(sys.stdin)
except json.JSONDecodeError:
    sys.exit(1)
rows = data.get("result") or []
for i, p in enumerate(rows, 1):
    pid = p.get("projectId") or ""
    name = (p.get("displayName") or "").replace("\t", " ")
    print(f"{i}\t{pid}\t{name}")
' >"${FB_LIST_TMP}"; then
    echo "error: Could not list Firebase projects (is \`firebase login\` done?)." >&2
    rm -f "${FB_LIST_TMP}"
    FB_LIST_TMP=""
    exit 1
  fi
  if [[ ! -s "${FB_LIST_TMP}" ]]; then
    echo "error: No Firebase projects returned for this account." >&2
    rm -f "${FB_LIST_TMP}"
    FB_LIST_TMP=""
    exit 1
  fi
}

print_firebase_projects_list() {
  echo "Your Firebase projects:"
  echo ""
  while IFS=$'\t' read -r num pid dname; do
    printf "  %2s)  %s  —  %s\n" "${num}" "${dname}" "${pid}"
  done <"${FB_LIST_TMP}"
  echo ""
}

# Accepts a row number (from the list) or a raw project id / alias.
resolve_firebase_project_id() {
  local raw="$1"
  if [[ "${raw}" =~ ^[0-9]+$ ]]; then
    while IFS=$'\t' read -r num pid _dname; do
      if [[ "${num}" == "${raw}" ]]; then
        echo "${pid}"
        return 0
      fi
    done <"${FB_LIST_TMP}"
    echo "error: Invalid project number: ${raw}" >&2
    return 1
  fi
  echo "${raw}"
}

echo ""
echo "Firebase / FlutterFire — per-flavor configure"
echo "App root: ${APP_ROOT}"
echo ""

require_firebase_cli
fetch_firebase_projects_tsv
print_firebase_projects_list

read -r -p "Use one Firebase project for all flavors? [Y/n]: " single_project_yn
single_project_yn="${single_project_yn:-Y}"
SHARED_PROJECT=""
if [[ "${single_project_yn}" =~ ^[Yy] ]]; then
  read -r -p "Firebase project (list # or Project ID): " _shared_choice
  if [[ -z "${_shared_choice}" ]]; then
    echo "error: A project is required for single-project mode." >&2
    exit 1
  fi
  SHARED_PROJECT="$(resolve_firebase_project_id "${_shared_choice}")" || exit 1
fi

read -r -p "(Optional) Expected prod Android applicationId for sanity check (empty to skip): " BASE_PACKAGE

declare -a FLAVORS
declare -a ANDROID_IDS
declare -a IOS_BUNDLES
declare -a PROJECT_IDS

while true; do
  echo ""
  read -r -p "Flavor key (Gradle productFlavor / lib/firebase/<flavor>/), empty to finish: " flavor
  if [[ -z "${flavor}" ]]; then
    break
  fi

  read -r -p "  Android applicationId for '${flavor}': " android_id
  if [[ -z "${android_id}" ]]; then
    echo "error: Android applicationId is required." >&2
    exit 1
  fi

  read -r -p "  iOS bundle identifier for '${flavor}': " ios_bundle
  if [[ -z "${ios_bundle}" ]]; then
    echo "error: iOS bundle identifier is required." >&2
    exit 1
  fi

  project_for_env="${SHARED_PROJECT}"
  if [[ -z "${SHARED_PROJECT}" ]]; then
    read -r -p "  Firebase project for '${flavor}' (list # or Project ID): " _proj_choice
    if [[ -z "${_proj_choice}" ]]; then
      echo "error: Firebase project is required." >&2
      exit 1
    fi
    project_for_env="$(resolve_firebase_project_id "${_proj_choice}")" || exit 1
  fi

  if [[ -n "${BASE_PACKAGE}" && "${flavor}" == "prod" && "${android_id}" != "${BASE_PACKAGE}" ]]; then
    echo "warning: prod Android id '${android_id}' does not match expected base '${BASE_PACKAGE}'."
    read -r -p "Continue anyway? [y/N]: " confirm
    if [[ ! "${confirm}" =~ ^[Yy] ]]; then
      echo "Aborted."
      exit 1
    fi
  fi

  FLAVORS+=("${flavor}")
  ANDROID_IDS+=("${android_id}")
  IOS_BUNDLES+=("${ios_bundle}")
  PROJECT_IDS+=("${project_for_env}")
done

if [[ ${#FLAVORS[@]} -eq 0 ]]; then
  echo "No flavors entered; nothing to do."
  exit 0
fi

echo ""
echo "Running flutterfire configure for ${#FLAVORS[@]} flavor(s)..."
echo ""

for i in "${!FLAVORS[@]}"; do
  flavor="${FLAVORS[$i]}"
  android_id="${ANDROID_IDS[$i]}"
  ios_bundle="${IOS_BUNDLES[$i]}"
  project_id="${PROJECT_IDS[$i]}"

  mkdir -p "android/app/src/${flavor}" "ios/Firebase/${flavor}" "lib/firebase/${flavor}"

  echo ">>> [${flavor}] project=${project_id}"
  echo "    Android: ${android_id}"
  echo "    iOS:     ${ios_bundle}"
  echo ""

  dart run flutterfire_cli:flutterfire configure \
    --yes \
    --project="${project_id}" \
    --platforms=android,ios \
    --android-package-name="${android_id}" \
    --ios-bundle-id="${ios_bundle}" \
    --out="lib/firebase/${flavor}/firebase_options.dart" \
    --android-out="android/app/src/${flavor}/google-services.json" \
    --ios-out="ios/Firebase/${flavor}/GoogleService-Info.plist" \
    --overwrite-firebase-options

  # Remove default locations if the CLI still wrote them (avoids wrong flavor being picked up).
  rm -f android/app/google-services.json ios/Runner/GoogleService-Info.plist

  echo ""
done

echo "Done. Android: android/app/src/<flavor>/google-services.json"
echo "       iOS:    ios/Firebase/<flavor>/GoogleService-Info.plist (copied into the app at build time)"
echo "       Dart:   lib/firebase/<flavor>/firebase_options.dart"
echo ""
echo "Manual verification:"
echo "  cd apps/preppy_app && flutter analyze"
echo "  flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=config/env.dev.json"
echo "  (repeat for staging/prod; on macOS use Xcode schemes dev / staging / prod for iOS.)"
