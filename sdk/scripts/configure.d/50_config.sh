#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017 ANSSI. All rights reserved.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${CURRENT_SDK_PRODUCT}/${CURRENT_SDK_RECIPE}/scripts/prelude.sh

LOCALE="${CURRENT_PRODUCT_PROPERTY['system.locale']}"
TIMEZONE="${CURRENT_PRODUCT_PROPERTY['system.timezone']}"
KEYMAP="${CURRENT_PRODUCT_PROPERTY['system.keymap']}"

sdk_info "Create default required files in /etc"
systemd-tmpfiles \
    --root="${CURRENT_OUT_ROOT}" \
    --create \
    --prefix="/etc" \

install -dm 0755 -o 0 -g 0 "${CURRENT_OUT_ROOT}/etc/tmpfiles.d"

sdk_info "Set locale, keymap and timezone"
systemd-firstboot \
    --root="${CURRENT_OUT_ROOT}" \
    --locale="${LOCALE}" \
    --keymap="${KEYMAP}" \
    --timezone="${TIMEZONE}"

# Split locale into the locale (required for locale generation command line):
locale_lang='' charmap=''
IFS=. read -r locale_lang charmap <<< "${LOCALE}"

# Safety checks on locale generation ability:
if [[ ! -f "${CURRENT_OUT_ROOT}/usr/share/i18n/charmaps/${charmap}.gz" ]]; then
    sdk_die "Charmap \"${charmap}\" seems absent from root (i.e. in /usr/share/i18n/charmaps)."
fi
if [[ ! -f "${CURRENT_OUT_ROOT}/usr/share/i18n/locales/${locale_lang}" ]]; then
    sdk_die "Locale language \"${locale_lang}\" seems absent from root (i.e. in /usr/share/i18n/locales)."
fi

sdk_info "Generating locale \"${LOCALE}\"..."
# Sadly enough, we need to resort to a chroot to generate the required locale
# within CURRENT_OUT_ROOT. :( Therefore, we need to create some device nodes:
rm -rf "${CURRENT_OUT_ROOT}/dev"
install -m 755 -o 0 -g 0 -d "${CURRENT_OUT_ROOT}/dev"
mknod -m 666 "${CURRENT_OUT_ROOT}/dev/null" c 1 3
mknod -m 666 "${CURRENT_OUT_ROOT}/dev/full" c 1 7
mknod -m 666 "${CURRENT_OUT_ROOT}/dev/ptmx" c 5 2
mknod -m 644 "${CURRENT_OUT_ROOT}/dev/random" c 1 8
mknod -m 644 "${CURRENT_OUT_ROOT}/dev/urandom" c 1 9
mknod -m 666 "${CURRENT_OUT_ROOT}/dev/zero" c 1 5
mknod -m 666 "${CURRENT_OUT_ROOT}/dev/tty" c 5 0

# Do not use the script locale-gen as it requires way too much runtime
# dependencies that we do not want to add in the Core when non instrumented
# (i.e. Bash, Awk, sed, etc.):
env -i chroot "${CURRENT_OUT_ROOT}" /usr/bin/env \
    localedef -i "${locale_lang}" -f "${charmap}" "${LOCALE}" \
        || sdk_die "Failure in generating locale \"${LOCALE}\"."

available_locales=()
readarray -t available_locales <<< \
    "$(env -i chroot "${CURRENT_OUT_ROOT}" /usr/bin/env localedef --list-archive)"

# Cleanup /dev created especially for chroot:
rm -rf "${CURRENT_OUT_ROOT}/dev"
install -m 755 -o 0 -g 0 -d "${CURRENT_OUT_ROOT}/dev"

# It is the normal behavior of readarray to create an array with one empty
# element when the input is empty: filter out this case then:
if [[ "${#available_locales[@]}" -eq 1 && -z "${available_locales[0]}" ]]; then
    sdk_die "UNEXPECTED ERROR: List of available locales appears empty even after locale generation."
fi

sdk_info "Available generated locales:"$'\n'"  ${available_locales[*]}"


# vim: set ts=4 sts=4 sw=4 et ft=sh:
