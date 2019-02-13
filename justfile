# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017 ANSSI. All rights reserved.

all: core efiboot

sdk:
    just sdk/all

sdk_debian:
    just sdk_debian/all

core:
    just core/all

efiboot:
    just efiboot/all

build:
    just core/build
    just efiboot/build

image:
    just core/image
    just efiboot/image

configure:
    just core/configure
    just efiboot/configure

bundle:
    just core/bundle
    just efiboot/bundle

qemu:
    just qemu/bundle
    just qemu/run

# vim: set ts=4 sts=4 sw=4 et ft=sh:
