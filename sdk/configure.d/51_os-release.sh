#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017 ANSSI. All rights reserved.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${COSMK_SDK_PRODUCT}/${COSMK_SDK_RECIPE}/prelude.sh

COMMON_NAME="${COSMK_PRODUCT_COMMON_NAME}"
SHORT_NAME="${COSMK_PRODUCT_SHORT_NAME}"
HOMEPAGE="${COSMK_PRODUCT_HOMEPAGE}"

sdk_info "Customizing /usr/lib/os-release."
cat <<EOF > "${CURRENT_OUT_ROOT}/usr/lib/os-release"
NAME="${COMMON_NAME}"
PRETTY_NAME="${COMMON_NAME} ${COSMK_PRODUCT_TAINTED_VERSION} (${COSMK_RECIPE})"
ID="${SHORT_NAME}-${COSMK_RECIPE}"
ID_LIKE=gentoo
VERSION="${COSMK_PRODUCT_TAINTED_VERSION}"
VERSION_ID="${COSMK_PRODUCT_TAINTED_VERSION}"
HOME_URL="${HOMEPAGE}"
SUPPORT_URL="${HOMEPAGE}"
BUG_REPORT_URL="${HOMEPAGE}"
EOF

# vim: set ts=4 sts=4 sw=4 et ft=sh:
