#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017 ANSSI. All rights reserved.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${COSMK_SDK_PRODUCT}/${COSMK_SDK_RECIPE}/prelude.sh

LOCALE="${COSMK_PRODUCT_ENV_LOCALE}"
TIMEZONE="${COSMK_PRODUCT_ENV_TIMEZONE}"
KEYMAP="${COSMK_PRODUCT_ENV_KEYMAP}"

sdk_info "Create default required files in /etc"
systemd-tmpfiles \
    --root="${CURRENT_OUT_ROOT}" \
    --create \
    --prefix="/etc" \

install -dm 0755 -o 0 -g 0 "${CURRENT_OUT_ROOT}/etc/tmpfiles.d"

sdk_info "Set keymap to \"${KEYMAP}\"."
echo "KEYMAP=${KEYMAP}" >> "${CURRENT_OUT_ROOT}/etc/vconsole.conf"

# Setting timezone with some pre-checks:
sdk_info "Setting timezone to \"${TIMEZONE}\"."
if [[ ! "${TIMEZONE}" =~ ^[a-zA-Z0-9/_\+\-]+$ ]]; then
    sdk_die "Timezone \"${TIMEZONE}\" is invalid, should be a IANA timezone name."
elif [[ ! -f "${CURRENT_OUT_ROOT}/usr/share/zoneinfo/${TIMEZONE}" ]]; then
    sdk_die "Timezone \"${TIMEZONE}\" is unfound in ROOT. Cannot set this timezone."
else
    ln -snf "/usr/share/zoneinfo/${TIMEZONE}" "${CURRENT_OUT_ROOT}/etc/localtime"
fi

# Split locale into the locale (required for locale generation command line):
locale_lang='' charmap=''
IFS=. read -r locale_lang charmap <<< "${LOCALE}"
unregionalized_locale_lang="${locale_lang%%_*}"

# Safety checks on locale generation ability:
if [[ ! -f "${CURRENT_OUT_ROOT}/usr/share/i18n/charmaps/${charmap}.gz" ]]; then
    sdk_die "Charmap \"${charmap}\" seems absent from root (i.e. in /usr/share/i18n/charmaps)."
fi
if [[ ! -f "${CURRENT_OUT_ROOT}/usr/share/i18n/locales/${locale_lang}" ]]; then
    sdk_die "Locale language \"${locale_lang}\" seems absent from root (i.e. in /usr/share/i18n/locales)."
fi

sdk_info "Generating locale \"${LOCALE}\"..."
# Sadly enough, we need to resort to a chroot to generate the required locale
# within CURRENT_OUT_ROOT. Do not use the script locale-gen as it requires way
# too much runtime dependencies that we do not want to add in the Core when non
# instrumented (i.e. Bash, Awk, sed, etc.):
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

sdk_info "Setting \"${LOCALE}\" as default locale."
# LANG should be the only locale setting to be set to control all the other
# "LC_*" settings:
target_LANG="${LOCALE}"
# Prefer using regionalized language, and if not available then fallback to
# unregionalized language, and if also not available, then fallback to English.
# This LANGUAGE setting is related to gettext, not glibc locales.
target_LANGUAGE="${locale_lang}:${unregionalized_locale_lang}:en"

cat <<EOF > "${CURRENT_OUT_ROOT}/etc/locale.conf"
# Automatically generated by the CLIP OS build chain:
LANG='${target_LANG}'
LANGUAGE='${target_LANGUAGE}'
EOF
# Note: This file is sourced by the /etc/profile from Gentoo defaults (pulled
# in by baselayout):
cat <<EOF >> "${CURRENT_OUT_ROOT}/etc/profile.env"
export LANG='${target_LANG}'
export LANGUAGE='${target_LANGUAGE}'
EOF

# vim: set ts=4 sts=4 sw=4 et ft=sh: