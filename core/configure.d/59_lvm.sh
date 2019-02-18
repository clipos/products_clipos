#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017 ANSSI. All rights reserved.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${CURRENT_SDK_PRODUCT}/${CURRENT_SDK_RECIPE}/scripts/prelude.sh

# Reconsider this if it turns out we need those backups
sdk_info "Disable backup & archive for LVM"
sed -i 's|backup = 1|backup = 0|g'   "${CURRENT_OUT_ROOT}/etc/lvm/lvm.conf"
sed -i 's|archive = 1|archive = 0|g' "${CURRENT_OUT_ROOT}/etc/lvm/lvm.conf"

# vim: set ts=4 sts=4 sw=4 et ft=sh:
