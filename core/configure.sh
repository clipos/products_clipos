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
${configure}/21_core_users.sh
${configure}/29_debug_no_root_password.sh
${configure}/31_extract_boot.sh
${configure}/40_fstab.sh
${configure}/41_dev_proc_sys.sh
${configure}/42_hosts.sh
${configure}/50_config.sh
${configure}/51_os-release.sh
${configure}/54_systemd.sh
${configure}/56_network.sh
${configure}/57_sshd.sh
${configure}/58_ipsec.sh
${configure}/58_update.sh
${configure}/59_lvm.sh
${configure}/60_chrony.sh
${configure}/60_rsyslog.sh
${configure}/80_nosuid.sh
${configure}/89_empty_var.sh
${configure}/90_config_cleanup.sh
${configure}/99_final_cleanup.sh

# vim: set ts=4 sts=4 sw=4 et ft=sh:
