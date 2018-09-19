#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017-2018 ANSSI. All rights reserved.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${CURRENT_SDK_PRODUCT}/${CURRENT_SDK_RECIPE}/scripts/prelude.sh

einfo "Set fixed known machine-id & hostname for initramfs."
SHORT_NAME="${CURRENT_PRODUCT_PROPERTY['short_name']}"
echo "${SHORT_NAME:?}" > "${CURRENT_OUT_ROOT}/etc/hostname"
echo "${SHORT_NAME:?}" | md5sum | awk '{print $1}' > "${CURRENT_OUT_ROOT}/etc/machine-id"
