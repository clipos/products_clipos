#!/bin/sh
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017-2018 ANSSI. All rights reserved.

# This file is set up as a dracut hook to mount the stateful part of the core
# (i.e., the part of the core filesystem which is read+write) as it is
# absolutely needed very early in the system boot sequence and cannot be
# delegated to the systemd unit/generator that processes `/etc/fstab` (because
# parts of systemd in the core require contents stored in /mnt/state, such as
# /etc/machine-id).
#
# Remark: This is one of the few (the only one at time of writing) mountpoints
# to be left to dracut (the initramfs infrastructure) and not fstab.
#
# WARNING: This mountpoint **MUST** be `rw` **AND** `nodev,nosuid,noexec`,
# otherwise the system-wide enforcement of W^X (see the security principles and
# architecture design in the CLIP OS documentation) would be broken.

mount /dev/mapper/VG_NAME-core_state /sysroot/mnt/state -t ext4 -o rw,nodev,noexec,nosuid
