#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017 ANSSI. All rights reserved.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${CURRENT_SDK_PRODUCT}/${CURRENT_SDK_RECIPE}/scripts/prelude.sh

dracut_config="/mnt/products/${CURRENT_PRODUCT}/${CURRENT_RECIPE}/configure.d/config/dracut"
dracut_moddir="${CURRENT_OUT_ROOT}/usr/lib/dracut/modules.d/"

sdk_info "Setup dracut configuration for core state mount"
install -d -m 0755 -o 0 -g 0 "${dracut_moddir}/11clipos-core-state"
install -m 0755 -o 0 -g 0 \
    "${dracut_config}/11clipos-core-state/module-setup.sh" \
    "${dracut_config}/11clipos-core-state/mount-core-state.sh" \
    "${dracut_moddir}/11clipos-core-state"

sdk_info "Setup dracut configuration for state partition content checks"
install -d -m 0755 -o 0 -g 0 "${dracut_moddir}/90clipos-check-state"
install -m 0755 -o 0 -g 0 \
    "${dracut_config}/90clipos-check-state/module-setup.sh" \
    "${dracut_config}/90clipos-check-state/clipos-check-state.sh" \
    "${dracut_moddir}/90clipos-check-state"

readonly VG_NAME="${CURRENT_PRODUCT_PROPERTY['system.disk_layout.vg_name']}"
if [[ "${CURRENT_RECIPE_INSTRUMENTATION_LEVEL}" -ge 1 ]]; then
    readonly REQUIRE_TPM=false
    readonly BRUTEFORCE_LOCKOUT=false
else
    readonly REQUIRE_TPM=true
    readonly BRUTEFORCE_LOCKOUT=true
fi
export VG_NAME REQUIRE_TPM BRUTEFORCE_LOCKOUT
replace_placeholders "${dracut_moddir}/11clipos-core-state/mount-core-state.sh"

# vim: set ts=4 sts=4 sw=4 et ft=sh:
