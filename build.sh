#!/usr/bin/env bash
set -euo pipefail

ZMK_DIR="$(realpath "$(dirname "$0")/../zmk")"
CONFIG_DIR="$(realpath "$(dirname "$0")")"
PROSPECTOR_DIR="$(realpath "$(dirname "$0")/../prospector-zmk-module")"
IMAGE="zmk-build:arm-4.1.0"

RUN="container run --rm \
  -v ${ZMK_DIR}:/zmk \
  -v ${CONFIG_DIR}:/zmk-config \
  -v ${PROSPECTOR_DIR}:/prospector-zmk-module"

COMMON_ARGS="-DZMK_CONFIG=/zmk-config/config -DZMK_EXTRA_MODULES=/zmk-config;/prospector-zmk-module"

echo "==> west update"
$RUN -w /zmk $IMAGE west update

echo "==> cradio_left (nice_nano//zmk)"
$RUN -w /zmk/app $IMAGE \
  west build -p -d build/cradio_left -b 'nice_nano//zmk' -- \
    -DSHIELD=cradio_left \
    -DCONFIG_ZMK_SPLIT=y -DCONFIG_ZMK_SPLIT_ROLE_CENTRAL=n \
    $COMMON_ARGS

echo "==> cradio_right (nice_nano//zmk)"
$RUN -w /zmk/app $IMAGE \
  west build -p -d build/cradio_right -b 'nice_nano//zmk' -- \
    -DSHIELD=cradio_right \
    -DCONFIG_ZMK_SPLIT=y -DCONFIG_ZMK_SPLIT_ROLE_CENTRAL=n \
    $COMMON_ARGS

echo "==> cradio_dongle (xiao_ble//zmk)"
$RUN -w /zmk/app $IMAGE \
  west build -p -d build/cradio_dongle -b 'xiao_ble//zmk' -- \
    "-DSHIELD=cradio_dongle prospector_adapter" \
    $COMMON_ARGS

echo "==> settings_reset (nice_nano//zmk)"
$RUN -w /zmk/app $IMAGE \
  west build -p -d build/settings_reset_nn -b 'nice_nano//zmk' -- \
    -DSHIELD=settings_reset \
    $COMMON_ARGS

echo "==> settings_reset (xiao_ble//zmk)"
$RUN -w /zmk/app $IMAGE \
  west build -p -d build/settings_reset_xiao -b 'xiao_ble//zmk' -- \
    -DSHIELD=settings_reset \
    $COMMON_ARGS

echo ""
echo "==> Copying firmware"
OUT_DIR="$(realpath "$(dirname "$0")/build")"
mkdir -p "$OUT_DIR"

copy_fw() {
  local name="$1"
  local src="${ZMK_DIR}/app/build/${name}/zephyr/zmk.uf2"
  local dest="${OUT_DIR}/${name}.uf2"
  cp "$src" "$dest"
  echo "    ${dest}"
}

copy_fw cradio_left
copy_fw cradio_right
copy_fw cradio_dongle
copy_fw settings_reset_nn
copy_fw settings_reset_xiao

echo ""
"$(dirname "$0")/draw.sh"

echo ""
echo "Build complete."
