#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2018 ANSSI. All rights reserved.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${CURRENT_SDK_PRODUCT}/${CURRENT_SDK_RECIPE}/scripts/prelude.sh

# Cleanup
rm -rf "${CURRENT_OUT}/var.debug"

if [[ "${CURRENT_RECIPE_INSTRUMENTATION_LEVEL}" -ge 1 ]]; then
    einfo "DEBUG: Start with an empty /var"
    rm -rf "${CURRENT_OUT_ROOT}/var"
    install -o 0 -g 0 -m 0755 -d "${CURRENT_OUT_ROOT}/var"

    einfo "DEBUG: Simulate first boot /var setup"
    systemd-tmpfiles \
        --root="${CURRENT_OUT_ROOT}" \
        --create \
        --prefix="/var"

    # Move /var out of / for debug (won't be included anywhere).
    einfo "DEBUG: Move /var to ../var.debug"
    mv "${CURRENT_OUT_ROOT}/var" "${CURRENT_OUT}/var.debug"
fi

einfo "Turn /var into a symbolic link to /mnt/state/core/var"
rm -rf "${CURRENT_OUT_ROOT}/var"
ln -s "/mnt/state/core/var" "${CURRENT_OUT_ROOT}/var"

# vim: set ts=4 sts=4 sw=4 et ft=sh:
