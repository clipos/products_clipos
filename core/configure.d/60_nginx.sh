#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2018 ANSSI. All rights reserved.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${CURRENT_SDK_PRODUCT}/${CURRENT_SDK_RECIPE}/scripts/prelude.sh

readonly nginx_config="/mnt/products/${CURRENT_PRODUCT}/${CURRENT_RECIPE}/configure.d/config/"
readonly factory="/usr/share/factory"

# Empty /etc/tmpfiles.d/nginx.conf
echo -n "" > "${CURRENT_OUT_ROOT}/etc/tmpfiles.d/nginx.conf"


einfo "Install custom nginx config in factory"
install -o 0 -g 0 -m 0750 -d "${CURRENT_OUT_ROOT}/${factory}/nginx"
install -o 0 -g 0 -m 640 \
    "${nginx_config}/nginx.conf" \
    "${CURRENT_OUT_ROOT}/${factory}/nginx/nginx.conf"

cat >> "${CURRENT_OUT_ROOT}/etc/tmpfiles.d/nginx.conf" << EOF
d /mnt/state/core/etc/nginx 0750 root nginx
C /mnt/state/core/etc/nginx/nginx.conf 0640 root nginx - ${factory}/nginx/nginx.conf
EOF

# Remove default nginx config & setup symbolic link
rm "${CURRENT_OUT_ROOT}/etc/nginx/nginx.conf"
ln -s "/mnt/state/core/etc/nginx/nginx.conf" "${CURRENT_OUT_ROOT}/etc/nginx/nginx.conf"

# vim: set ts=4 sts=4 sw=4 et ft=sh:
