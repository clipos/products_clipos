#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017 ANSSI. All rights reserved.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${COSMK_SDK_PRODUCT}/${COSMK_SDK_RECIPE}/prelude.sh

sdk_info "Create the system directories receiving mountpoints."
rm -rf "${CURRENT_OUT_ROOT}"/{dev,proc,sys}
install -o 0 -g 0 -m 0755 -d "${CURRENT_OUT_ROOT}"/dev
install -o 0 -g 0 -m 0555 -d "${CURRENT_OUT_ROOT}"/{proc,sys}

# vim: set ts=4 sts=4 sw=4 et ft=sh:
