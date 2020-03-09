#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017 ANSSI. All rights reserved.

# CLIP OS SDK setup script

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

if [[ -z "${COSMK_ACTION:+x}" ]] || [[ "${COSMK_ACTION}" != "bootstrap" ]]; then
    >&2 echo "Not running inside a COSMK bootstrapped container!"
    exit 1
fi
# Touch a special file to mark the SDK rootfs
touch "/.sdk"

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${COSMK_SDK_PRODUCT}/${COSMK_SDK_RECIPE}/prelude.sh

# Setup Portage as there is no prerun command in the bootstrap action:
${CURRENT_SDK}/setup-portage.sh

# Needed to get EMERGE_BUILDROOTWITHBDEPS_OPTS:
source "${CURRENT_SDK}/emergeopts.sh"

# Workaround for lz4 build
portage_vars_to_delete=(
    PKGDIR
    BINPKG_COMPRESS
    BINPKG_COMPRESS_FLAGS
)
for var in "${portage_vars_to_delete[@]}"; do
    sed -i -E -e '/^[ \t]*'"${var}"'=/d' /etc/portage/make.conf
done
cat <<EOF >> /etc/portage/make.conf
PKGDIR='${CURRENT_CACHE_PKG}/.binpkgs-bz2'
EOF

# Setup EXIT trap to restore log and distfiles ownership to root on successful
# and unsuccessful script exits.
restore_log_ownership() {
    chown -R "$(stat -c '%u' /mnt/assets):$(stat -c '%g' /mnt/assets)" \
        "${CURRENT_CACHE}/log" '/mnt/assets/distfiles'
}
trap restore_log_ownership EXIT

# Needed for a time-optimal compression of the binpkgs.
emerge ${EMERGE_BUILDROOTWITHBDEPS_OPTS} app-arch/lz4

# Now reset portage setup:
${CURRENT_SDK}/setup-portage.sh

# Install equery and retrieve distfiles for installed packages in the Gentoo stage3:
emerge ${EMERGE_BUILDROOTWITHBDEPS_OPTS} app-portage/gentoolkit
readarray equery_list_array < <(equery list --format='$category $name $version $fullversion' '*')
for equery_list_line in "${equery_list_array[@]}"; do
    # skip over the element if this one is empty
    [[ -z ${equery_list_line} ]] && continue
    # split the output line from the equery list
    IFS=' ' read -ra pkg_info <<< "${equery_list_line}"
    category="${pkg_info[0]:-}"  # the ebuild category (e.g. "sys-apps")
    name="${pkg_info[1]:-}"  # the package name
    version="${pkg_info[2]:-}"  # e.g. 2.0.1
    fullversion="${pkg_info[3]:-}"   # e.g. 2.0.1-r6

    portage_tree="/mnt/src/portage/gentoo"
    ebuild_fullpath="${portage_tree}/${category}/${name}/${name}-${fullversion}.ebuild"

    shopt -s nullglob
    ebuilds_all_revisions=("${portage_tree}/${category}/${name}/${name}-${version}"*".ebuild")
    ebuilds_all_versions=("${portage_tree}/${category}/${name}/${name}"*".ebuild")
    shopt -u nullglob

    if [[ -f "${ebuild_fullpath}" ]]; then
        ebuild "${ebuild_fullpath}" fetch
    elif [[ "${#ebuilds_all_revisions[@]}" -ne 0 ]]; then
        # If we are unlucky and the ebuild does not exist anymore, we fetch
        # sources for all revisions corresponding to this package version.
        for f in "${ebuilds_all_revisions[@]}"; do
            ebuild "${f}" fetch
        done
    elif [[ "${#ebuilds_all_versions[@]}" -ne 0 ]]; then
        # If we are extremely unlucky (no matching version), we fetch sources
        # for all versions of this package.
        for f in "${ebuilds_all_versions[@]}"; do
            ebuild "${f}" fetch
        done
    else
        echo >&2 "bootstrap.sh: Could not find any ebuild to fetch the distfile(s) for the package atom \"=${category}/${name}-${fullversion}\"."
        exit 1
    fi
done

# sys-fs/eudev and sys-apps/sysvinit are blockers for the packages to be
# installed next (ensure to get rid of them even in the @system package set):
emerge --rage-clean sys-apps/sysvinit sys-fs/eudev

# Update the packages according to profile and overlays (this will install also
# the packages from @sdk-world).
emerge ${EMERGE_BUILDROOTWITHBDEPS_OPTS} --update --deep --newuse @world \
    sys-apps/systemd virtual/udev sys-apps/pciutils clipos-meta/clipos-sdk

# Remove now unnecessary packages
CLEAN_DELAY=0 emerge --depclean

# Merge all etc updates
etc-update --verbose --automode -5

# vim: set ts=4 sts=4 sw=4 et ft=sh:
