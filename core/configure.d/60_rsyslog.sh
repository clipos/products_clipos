#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2020 ANSSI. All rights reserved.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${COSMK_SDK_PRODUCT}/${COSMK_SDK_RECIPE}/prelude.sh

sdk_info "Enable rsyslog by default"
systemctl --root="${CURRENT_OUT_ROOT}" enable rsyslog

sdk_info "Installing default rsyslog configuration..."
install -o 0 -g 0 -m 644 \
    "${CURRENT_RECIPE}/configure.d/config/rsyslog/rsyslog.conf" \
    "${CURRENT_OUT_ROOT}/etc/rsyslog.conf"

# Hardened systemd unit and use environment file from state partition
install -o 0 -g 0 -m 755 -d "${CURRENT_OUT_ROOT}/etc/systemd/system/rsyslog.service.d"
install -o 0 -g 0 -m 0644 \
    "${CURRENT_RECIPE}/configure.d/config/rsyslog/security.conf" \
    "${CURRENT_OUT_ROOT}/etc/systemd/system/rsyslog.service.d/security.conf"

# Require IPsec for rsyslog transfert
install -o 0 -g 0 -m 0644 \
    "${CURRENT_RECIPE}/configure.d/config/ipsec0.conf" \
    "${CURRENT_OUT_ROOT}/etc/systemd/system/rsyslog.service.d/ipsec0.conf"

# Install host entry only for development builds
if [[ -n "${COSMK_INSTRUMENTATION_FEATURES+x}" ]]; then
    cat <<EOF >> "${CURRENT_OUT_ROOT}/etc/hosts"
172.27.100.10  logs.clip-os.org
EOF
fi

#vim: set ts=4 sts=4 sw=4 et ft=sh:
