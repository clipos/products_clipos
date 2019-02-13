#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017 ANSSI. All rights reserved.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${CURRENT_SDK_PRODUCT}/${CURRENT_SDK_RECIPE}/scripts/prelude.sh

cd "${CURRENT_OUT}"

einfo "Bundling the core root in a squashfs image..."
mksquashfs \
    "../configure/root" \
    "core.squashfs" \
    -noI -noD -noF -noX -no-duplicates -noappend


einfo "Formatting the core root with dm-verity..."
# The file in which is stored the output result of the command
# "veritysetup format" and in which the root hash can be found:
core_veritysetup_status_file="core.squashfs.verity.status"

# dm-verity setup
veritysetup format \
    --fec-device="core.squashfs.verity.fec" -- \
    "core.squashfs" "core.squashfs.verity" > "${core_veritysetup_status_file}"

# Retrieve root hash from "veritysetup format" status output:
gawk '(/^Root hash:/ && $NF ~ /^[0-9a-fA-F]+$/) { print $NF; }' \
    "${core_veritysetup_status_file}" > "core.squashfs.verity.roothash"

core_squashfs_size="$(stat -c '%s' "core.squashfs")"
core_verity_size="$(stat -c '%s' "core.squashfs.verity")"

core_bundled_hashoffset="$(( core_squashfs_size ))"
core_bundled_fecoffset="$(( core_squashfs_size + core_verity_size ))"

# Store verity root hash offset
echo "${core_bundled_hashoffset}" > "core.squashfs.verity.bundled.hashoffset"
# Store FEC data offset
echo "${core_bundled_fecoffset}"  > "core.squashfs.verity.bundled.fecoffset"

# Bundle squashfs contents with appended dm-verity information
cat "core.squashfs" "core.squashfs.verity" "core.squashfs.verity.fec" \
    > "core.squashfs.verity.bundled"

# vim: set ts=4 sts=4 sw=4 et ft=sh:
