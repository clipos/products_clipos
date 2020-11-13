#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2019 ANSSI. All rights reserved.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${COSMK_SDK_PRODUCT}/${COSMK_SDK_RECIPE}/prelude.sh

cp -a -T /mnt/out/${COSMK_PRODUCT}/${COSMK_PRODUCT_VERSION}/${COSMK_RECIPE}/image/root ${CURRENT_OUT_ROOT}

# vim: set ts=4 sts=4 sw=4 et ft=sh:
