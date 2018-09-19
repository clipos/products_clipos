#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017-2018 ANSSI. All rights reserved.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${CURRENT_SDK_PRODUCT}/${CURRENT_SDK_RECIPE}/scripts/prelude.sh

declare -a REMOVE_LIST

# Important note: this cleanup file is intended to work on the root tree
# resulting of the current recipe action AND NOT ON THE ROOT OF THE SDK
# ENVIRONMENT!
# This is the reason why, all the items of the REMOVE_LIST array are prefixed
# with the same variable "root" defined here:
readonly root="${CURRENT_OUT_ROOT:?}"

# TODO: Move portage db cleanup here and use emerge --unmerge
REMOVE_LIST+=(
    "$root"/usr/bin/awk
    "$root"/usr/bin/sed
)

REMOVE_LIST+=(
    "$root"/bin/chroot
    "$root"/usr/bin/chroot
)

einfo "Remove now unneeded files:"
for f in "${REMOVE_LIST[@]}"; do
    einfo "Removing: ${f}"
    rm -rf "${f}"
done

# vim: set ts=4 sts=4 sw=4 et ft=sh:
