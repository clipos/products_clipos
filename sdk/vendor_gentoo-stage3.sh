#!/usr/bin/env bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017-2018 ANSSI. All rights reserved.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# Get the basename of this program and the directory path to itself:
readonly PROGNAME="${BASH_SOURCE[0]##*/}"
readonly PROGPATH="$(realpath "${BASH_SOURCE[0]%/*}")"

# Full path to the vendor dirs:
readonly VENDOR="$(realpath "${PROGPATH}/../assets/gentoo")"

echo "TO DO: retrieve old scripts that fetch and verify a Gentoo stage3 image"
exit 1

# vim: set ts=4 sts=4 sw=4 et ft=sh:
