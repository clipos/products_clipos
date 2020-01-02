#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2018 ANSSI. All rights reserved.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${COSMK_SDK_PRODUCT}/${COSMK_SDK_RECIPE}/prelude.sh

sdk_info "Turn /var into a symbolic link to /mnt/state/core/var"
rm -rf "${CURRENT_OUT_ROOT}/var"
ln -s "/mnt/state/core/var" "${CURRENT_OUT_ROOT}/var"

# vim: set ts=4 sts=4 sw=4 et ft=sh:
