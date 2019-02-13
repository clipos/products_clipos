#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017 ANSSI. All rights reserved.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${CURRENT_SDK_PRODUCT}/${CURRENT_SDK_RECIPE}/scripts/prelude.sh

einfo "Remove existing users & groups in the SDK."
rm -f /etc/{passwd,group,shadow,gshadow}

einfo "Setup required users & groups for the SDK."
systemd-sysusers basic.conf systemd.conf

einfo "Setup required users & groups for the final root."
systemd-sysusers --root="${CURRENT_OUT_ROOT}" basic.conf systemd.conf

# vim: set ts=4 sts=4 sw=4 et ft=sh:
