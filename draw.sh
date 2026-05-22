#!/usr/bin/env bash
set -euo pipefail

CONFIG_DIR="$(realpath "$(dirname "$0")")"

echo "==> keymap-drawer: parse + draw"
uvx --from keymap-drawer keymap -c "${CONFIG_DIR}/keymap-drawer/config.yaml" \
  parse -z "${CONFIG_DIR}/config/cradio.keymap" \
  > "${CONFIG_DIR}/keymap-drawer/cradio.yaml"
uvx --from keymap-drawer keymap -c "${CONFIG_DIR}/keymap-drawer/config.yaml" \
  draw "${CONFIG_DIR}/keymap-drawer/cradio.yaml" \
  > "${CONFIG_DIR}/keymap-drawer/cradio.svg"
