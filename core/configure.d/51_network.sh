#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017-2018 ANSSI. All rights reserved.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${CURRENT_SDK_PRODUCT}/${CURRENT_SDK_RECIPE}/scripts/prelude.sh

einfo "Setup state directory for network config"
install -o 0 -g 0 -m 0755 -d "${CURRENT_OUT}/state/core/etc/systemd/network"
ln -sf "/mnt/state/core/etc/systemd/network" "${CURRENT_OUT_ROOT}/etc/systemd/network"

einfo "Enable systemd-networkd by default"
systemctl --root="${CURRENT_OUT_ROOT}" enable systemd-networkd

# FIXME: This is specific to the QEMU environment
einfo "Add default network configuration"
cat > "${CURRENT_OUT}/state/core/etc/systemd/network/10-wired.network" << EOF
[Match]
Name="en*"

[Network]
# FIXME
# DHCP=ipv4
Address=192.168.150.99/24
Gateway=192.168.150.1
DNS=192.168.150.1
EOF

# FIXME: Workaround script for quick network setup
cat > "${CURRENT_OUT_ROOT}/usr/bin/netsetup" << EOF
#!/bin/bash
ip addr add 192.168.150.99/24 dev enp0s3
ip link set dev enp0s3 up
ip route add default via 192.168.150.1 dev enp0s3
EOF
chmod 500 "${CURRENT_OUT_ROOT}/usr/bin/netsetup"

# vim: set ts=4 sts=4 sw=4 et ft=sh:
