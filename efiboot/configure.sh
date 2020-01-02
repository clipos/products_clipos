#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017 ANSSI. All rights reserved.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${COSMK_SDK_PRODUCT}/${COSMK_SDK_RECIPE}/prelude.sh

configure="/mnt/products/${COSMK_PRODUCT}/${COSMK_RECIPE}/configure.d"

${configure}/00_import_rootfs.sh
${configure}/10_cleanup.sh
${configure}/20_default_users.sh
${configure}/50_config.sh
${configure}/50_config_state.sh
${configure}/51_os-release.sh
${configure}/90_config_cleanup.sh
${configure}/95_dracut.sh
${configure}/96_secure_boot.sh

# vim: set ts=4 sts=4 sw=4 et ft=sh:
