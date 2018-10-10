#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017-2018 ANSSI. All rights reserved.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${CURRENT_SDK_PRODUCT}/${CURRENT_SDK_RECIPE}/scripts/prelude.sh

dracut_config_path="/mnt/products/${CURRENT_PRODUCT}/${CURRENT_RECIPE}/configure.d/config/dracut"

einfo "Setup dracut configuration for core root mount with DM-Verity"
install -d -m 0755 -o 0 -g 0 "${CURRENT_OUT_ROOT}/usr/lib/dracut/modules.d/10clipos-core-verity"
install -m 0755 -o 0 -g 0 \
    "${dracut_config_path}/10clipos-core-verity/module-setup.sh" \
    "${dracut_config_path}/10clipos-core-verity/verity-generator.sh" \
    "${CURRENT_OUT_ROOT}/usr/lib/dracut/modules.d/10clipos-core-verity"

einfo "Setup dracut configuration for core state mount"
install -d -m 0755 -o 0 -g 0 "${CURRENT_OUT_ROOT}/usr/lib/dracut/modules.d/11clipos-core-state"
install -m 0755 -o 0 -g 0 \
    "${dracut_config_path}/11clipos-core-state/module-setup.sh" \
    "${dracut_config_path}/11clipos-core-state/mount-core-state.sh" \
    "${CURRENT_OUT_ROOT}/usr/lib/dracut/modules.d/11clipos-core-state"

readonly vg_name="${CURRENT_PRODUCT_PROPERTY['system.disk_layout.vg_name']}"
sed -i 's|VG_NAME|'"${vg_name}"'|' \
    "${CURRENT_OUT_ROOT}/usr/lib/dracut/modules.d/11clipos-core-state/mount-core-state.sh"

# vim: set ts=4 sts=4 sw=4 et ft=sh:
