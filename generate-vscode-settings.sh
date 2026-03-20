#!/usr/bin/env bash
# Usage:
#   ./generate-vscode-settings.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"


# Check for -m flag
if [[ "${1:-}" == "-d" ]]; then
  OUTPUT_DIR="$SCRIPT_DIR"
  NVIM_EXE=""
fi

echo "This program can accept existing VSCode settings directory, in which case it will back up the current settings and generate a new one by merging in the settings favored by this project."

if [ ! -v OUTPUT_DIR ]; then
  echo "Choose VSCode settings directory (default: 1): "
  echo "1) Temporary directory"
  echo "2) ./"
  echo "3) Custom directory"
  read choice
  case "${choice}" in
    1|"")
      OUTPUT_DIR="$(mktemp -d "${TMPDIR:-/tmp}/ansible-vscode-out.XXXXXX")"
      ;;
    2)
      OUTPUT_DIR="./"
      ;;
    3)
      read -rp "Enter path: " OUTPUT_DIR
      ;;
    *)
      echo "Invalid choice."
      exit -1
  esac
fi

if [ ! -v NVIM_EXE ]; then
  echo "Choose path to nvim.exe (default: 1): "
  echo "1) None"
  echo "2) scoop default"
  echo "3) Custom directory"
  read choice
  case "${choice}" in
    "None"|"")
      NVIM_EXE=""
      break
      ;;
    "scoop default")
      read -rp "Enter your Windows home directory: C:\\Users\\" USER_NAME
      NVIM_EXE="C:\\Users\\$USER_NAME\\scoop\\shims\\nvim.exe"
      break
      ;;
    "Custom directory")
      read -rp "Enter path: " OUTPUT_DIR
      break
      ;;
    *)
      echo "Invalid choice."
      exit -1
  esac
fi

mkdir -p "$OUTPUT_DIR"

ansible-playbook \
    --inventory 'localhost,' \
  --connection local \
    --extra-vars "vscode_settings_dir=${OUTPUT_DIR}" \
    --extra-vars "nvim_exe=${NVIM_EXE}" \
    "$SCRIPT_DIR/playbook.yml"

echo "Generated:"
echo "$OUTPUT_DIR/settings.json"
echo "%%%%%%%%%"
cat "$OUTPUT_DIR/settings.json"
echo
echo "%%%%%%%%%"
echo
echo
echo "$OUTPUT_DIR/keybindings.json"
echo "%%%%%%%%%"
cat "$OUTPUT_DIR/settings.json"
echo
echo "%%%%%%%%%"