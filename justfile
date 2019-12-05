# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017 ANSSI. All rights reserved.

all: core efiboot qemu

sdk:
    just sdk/all

sdk_debian:
    just sdk_debian/all

core:
    just core/all

efiboot:
    just efiboot/all

qemu:
    just qemu/all

# vim: set ts=4 sts=4 sw=4 et ft=sh:
