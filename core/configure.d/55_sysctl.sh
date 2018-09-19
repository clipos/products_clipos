#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017-2018 ANSSI. All rights reserved.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${CURRENT_SDK_PRODUCT}/${CURRENT_SDK_RECIPE}/scripts/prelude.sh

# Tune sysctls
einfo "Tune sysctls"
rm -f "${CURRENT_OUT_ROOT}/etc/sysctl.conf"
rm -rf "${CURRENT_OUT_ROOT}/etc/sysctl.d"
install -o 0 -g 0 -m 0755 -d "${CURRENT_OUT_ROOT}/etc/sysctl.d"

cat > "${CURRENT_OUT_ROOT}/etc/sysctl.d/hardening.conf" <<EOF
kernel.kptr_restrict = 2
kernel.yama.ptrace_scope = 1
kernel.perf_event_paranoid = 3
kernel.unprivileged_bpf_disabled = 1
kernel.tiocsti_restrict = 1
kernel.deny_new_usb = 0
kernel.device_sidechannel_restrict = 1
kernel.pid_max = 65536

fs.protected_symlinks = 1
fs.protected_hardlinks = 1
fs.suid_dumpable = 0

net.core.bpf_jit_harden = 2
EOF
