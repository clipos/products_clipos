#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017 ANSSI. All rights reserved.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${CURRENT_SDK_PRODUCT}/${CURRENT_SDK_RECIPE}/scripts/prelude.sh

einfo "Remove all setuid bit:"
find "${CURRENT_OUT_ROOT}" -perm -4000 -exec chmod -v u-s {} \;

einfo "List all files or directory with a sticky bit:"
find "${CURRENT_OUT_ROOT}" -perm -1000

einfo "List all files or directory with a setgid bit:"
find "${CURRENT_OUT_ROOT}" -perm -2000

# vim: set ts=4 sts=4 sw=4 et ft=sh:
