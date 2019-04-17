#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017 ANSSI. All rights reserved.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${CURRENT_SDK_PRODUCT}/${CURRENT_SDK_RECIPE}/scripts/prelude.sh

# Sadly enough, dracut does not provide an option to be able to work with
# objects (kernel, binaries, environment) from a detached root tree.
# For this reason, we are going to rely on a chroot(1) call into
# CURRENT_OUT_ROOT. :( Therefore, we need to create some device nodes in
# this future chroot in order for some programs to run properly.
rm -rf "${CURRENT_OUT_ROOT}/dev"
install -m 755 -o 0 -g 0 -d "${CURRENT_OUT_ROOT}/dev"
mknod -m 666 "${CURRENT_OUT_ROOT}/dev/null" c 1 3
mknod -m 666 "${CURRENT_OUT_ROOT}/dev/full" c 1 7
mknod -m 666 "${CURRENT_OUT_ROOT}/dev/ptmx" c 5 2
mknod -m 644 "${CURRENT_OUT_ROOT}/dev/random" c 1 8
mknod -m 644 "${CURRENT_OUT_ROOT}/dev/urandom" c 1 9
mknod -m 666 "${CURRENT_OUT_ROOT}/dev/zero" c 1 5
mknod -m 666 "${CURRENT_OUT_ROOT}/dev/tty" c 5 0

# vim: set ts=4 sts=4 sw=4 et ft=sh:
