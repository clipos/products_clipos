#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2020 ANSSI. All rights reserved.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${COSMK_SDK_PRODUCT}/${COSMK_SDK_RECIPE}/prelude.sh

sdk_info "Reset /etc/hosts"
rm "${CURRENT_OUT_ROOT}/etc/hosts"

# IPv4 and IPv6 localhost aliases
cat <<EOF >> "${CURRENT_OUT_ROOT}/etc/hosts"
127.0.0.1       localhost
::1             localhost
EOF

# Install host entry only for development builds
if [[ -n "${COSMK_INSTRUMENTATION_FEATURES+x}" ]]; then
    sdk_info "Adding development entries to /etc/hosts"
    # CLIP OS internal infrastructure services for Core services
    cat <<EOF >> "${CURRENT_OUT_ROOT}/etc/hosts"
172.27.100.10  update.clip-os.org
172.27.100.10  ntp.clip-os.org
172.27.100.10  logs.clip-os.org
EOF
fi

# vim: set ts=4 sts=4 sw=4 et ft=sh:
