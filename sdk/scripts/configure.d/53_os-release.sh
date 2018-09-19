#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017-2018 ANSSI. All rights reserved.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${CURRENT_SDK_PRODUCT}/${CURRENT_SDK_RECIPE}/scripts/prelude.sh

COMMON_NAME="${CURRENT_PRODUCT_PROPERTY['common_name']}"
SHORT_NAME="${CURRENT_PRODUCT_PROPERTY['short_name']}"
HOMEPAGE="${CURRENT_PRODUCT_PROPERTY['homepage']}"

einfo "Customizing /usr/lib/os-release."
cat <<EOF > "${CURRENT_OUT_ROOT}/usr/lib/os-release"
NAME="${COMMON_NAME:?}"
PRETTY_NAME="${COMMON_NAME:?} ${CURRENT_PRODUCT_TAINTED_VERSION:?} (${CURRENT_RECIPE:?})"
ID="${SHORT_NAME:?}-${CURRENT_RECIPE:?}"
ID_LIKE=gentoo
VERSION="${CURRENT_PRODUCT_TAINTED_VERSION:?}"
VERSION_ID="${CURRENT_PRODUCT_TAINTED_VERSION:?}"
HOME_URL="${HOMEPAGE}"
SUPPORT_URL="${HOMEPAGE}"
BUG_REPORT_URL="${HOMEPAGE}"
EOF

# vim: set ts=4 sts=4 sw=4 et ft=sh:
