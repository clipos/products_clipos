#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017-2018 ANSSI. All rights reserved.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${CURRENT_SDK_PRODUCT}/${CURRENT_SDK_RECIPE}/scripts/prelude.sh

einfo "Create directories for state partition mountpoints."
install -o 0 -g 0 -m 0555 -d "${CURRENT_OUT_ROOT}"/mnt/state

einfo "Create the core state directories."
rm -rf "${CURRENT_OUT}/state"
mkdir -p "${CURRENT_OUT}/state"

install -o 0 -g 0 -m 0755 -d "${CURRENT_OUT}/state/core"

einfo "Create required files in /var."
systemd-tmpfiles \
    --root="${CURRENT_OUT_ROOT}" \
    --create \
    --prefix="/var"

# TODO: Use tmpfiles.d config files to make sure all state folders are created
# during bootup if not available
# install -o 0 -g 0 -m 0755 -d "${CURRENT_OUT}/state/core/var"
cp -raT "${CURRENT_OUT_ROOT}/var" "${CURRENT_OUT}/state/core/var"
rm -rf "${CURRENT_OUT_ROOT}/var"
install -o 0 -g 0 -m 0755 -d "${CURRENT_OUT_ROOT}/var"

# Setup /var/log/journal
install -o 0 -g 0 -m 2755 -d "${CURRENT_OUT}/state/core/var/log/journal"
chgrp systemd-journal "${CURRENT_OUT}/state/core/var/log/journal"

# vim: set ts=4 sts=4 sw=4 et ft=sh:
