#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017-2018 ANSSI. All rights reserved.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${CURRENT_SDK_PRODUCT}/${CURRENT_SDK_RECIPE}/scripts/prelude.sh

einfo "Install sysuser config for nginx user"
echo "u nginx 999 \"nginx Web server\"" | tee > /dev/null \
    "/usr/lib/sysusers.d/nginx.conf" \
    "${CURRENT_OUT_ROOT}/usr/lib/sysusers.d/nginx.conf"

einfo "Setup nginx user for the SDK."
systemd-sysusers nginx.conf

einfo "Setup nginx user for the final root."
systemd-sysusers --root="${CURRENT_OUT_ROOT}" nginx.conf

# vim: set ts=4 sts=4 sw=4 et ft=sh:
