#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017-2018 ANSSI. All rights reserved.

# Portage configuration to be done each time a CLIP OS SDK is spawn.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${CURRENT_SDK_PRODUCT}/${CURRENT_SDK_RECIPE}/scripts/prelude.sh

# Needed to get EMERGE_INTELLIGIBLE_OPTS:
source /mnt/products/${CURRENT_SDK_PRODUCT}/${CURRENT_SDK_RECIPE}/scripts/portage/emergeopts.sh

# Compute optimal values for the number of jobs to allocate for make and
# emerge. Since we throttle the amount of CPU shares dedicated to the current
# SDK container, let's assume we can use all the CPU capacity available to us.
# _NPROCESSORS_ONLN still reports the real physical number of CPUs of the
# underlying machine (even if the CPU share is constrained by the container).
nproc="$(getconf _NPROCESSORS_ONLN)"  # more portable than nproc
make_jobs="$((${nproc} + 1))"  # + 1 for the main thread of make
emerge_jobs="${nproc}"

# Set default LOCALE with fallback to 'en_US.UTF-8' if property is not defined
LOCALE="${CURRENT_PRODUCT_PROPERTY['system.locale']:-'en_US.UTF-8'}"
L10N_LOCALE=${LOCALE/_/-}

# Drop everything we do not need in the Portage configuration and set some
# useful things
find /etc/portage -mindepth 1 -not -path /etc/portage/make.conf -delete
sed -i.bak -E -e '/^[ \t]*#/d' -e '/^[ \t]*$/d' /etc/portage/make.conf
# delete configuration values that we are going to overwrite
portage_vars_to_delete=(
    # PORTDIR is erased from make.conf because the Portage tree directory path
    # is left for the default defined in /etc/portage/repos.conf
    PORTDIR

    # Rewritten by ourselves below:
    DISTDIR
    PKGDIR
    FEATURES
    MAKEOPTS
    EMERGE_DEFAULT_OPTS
    ACCEPT_LICENSE
    LINGUAS
    L10N
    PORT_LOGDIR
    QA_STRICT_EXECSTACK
    QA_STRICT_FLAGS_IGNORED
    QA_STRICT_MULTILIB_PATHS
    QA_STRICT_PRESTRIPPED
    QA_STRICT_TEXTRELS
    QA_STRICT_WX_LOAD
)
for var in "${portage_vars_to_delete[@]}"; do
    sed -i -E -e '/^[ \t]*'"${var}"'=/d' /etc/portage/make.conf
done
# TODO: Once we have a CI, we should add 'getbinpkg' to FEATURES
# TODO: Disable 'parallel-install' for production builds
# TODO: Enable 'stricter' portage FEATURE (disabled due to QA failures).
cat <<EOF >> /etc/portage/make.conf
DISTDIR='/mnt/assets/distfiles'
PKGDIR='${CURRENT_CACHE_PKG}'
PORT_LOGDIR='${CURRENT_CACHE}/log'
BINPKG_COMPRESS='lz4'
BINPKG_COMPRESS_FLAGS='-1'
FEATURES='sandbox userfetch userpriv usersandbox nodoc noinfo noman strict parallel-install split-elog split-log -news unknown-features-warn'
MAKEOPTS='-j ${make_jobs}'
EMERGE_DEFAULT_OPTS='--jobs ${emerge_jobs} ${EMERGE_INTELLIGIBLE_OPTS}'
ACCEPT_LICENSE="-* @FREE"
LINGUAS="${LOCALE%_*} ${LOCALE%.*}"
L10N="${LOCALE%_*} ${L10N_LOCALE%.*}"
QA_STRICT_EXECSTACK="set"
QA_STRICT_FLAGS_IGNORED="set"
QA_STRICT_MULTILIB_PATHS="set"
QA_STRICT_PRESTRIPPED="set"
QA_STRICT_TEXTRELS="set"
QA_STRICT_WX_LOAD="set"
EOF

# Note: emerge may complain with the error "PORTAGE_BINHOST unset, but use is
# requested." but this can be ignored since we do not share the binpackages
# across machines (yet?).

# Declaring the Portage tree overlays
rm -rf /usr/portage
mkdir /etc/portage/repos.conf
for r in ${PORTAGE_OVERLAYS}; do
    repo=/mnt/src/portage/${r}
    [[ ! -d "${repo}" ]] && continue
    # this parses the layout.conf to get the repo-name defined in it
    reponame="$(sed -n -E 's/^[ \t]*repo-name[ \t]*=[ \t]*([^ \t]+).*$/\1/p' "${repo}/metadata/layout.conf")"
    # if not found, fall back to the old-style repo-name definition
    [[ -z "${reponame}" ]] && reponame="$(cat "${repo}/profiles/repo_name")"
    # and if still not foun, give up and use the name of the overlay directory
    [[ -z "${reponame}" ]] && reponame="$(basename "${repo}")"

    # Check that the current Portage repo is well declared in the
    # PORTAGE_OVERLAYS name list:
    if ! contains "${reponame}" ${PORTAGE_OVERLAYS:-}; then
        continue
    fi

    repoconf="/etc/portage/repos.conf/${reponame}.conf"
    if [[ "${reponame}" == 'gentoo' ]]; then
        # gentoo is always default
        echo "[DEFAULT]" >> "${repoconf}"
        echo "main-repo = gentoo" >> "${repoconf}"
        echo >> "${repoconf}"
    fi
    echo "[${reponame}]" >> "${repoconf}"
    echo "location = ${repo}" >> "${repoconf}"
    echo "auto-sync = no" >> "${repoconf}"
done

# Set the Portage profile depending on the current instrumentation level
portage_profile_suffix=""
if [[ "${CURRENT_ACTION}" == "build" ]] || [[ "${CURRENT_ACTION}" == "image" ]]; then
    if [[ "${CURRENT_RECIPE_INSTRUMENTATION_LEVEL}" -ge 1 ]]; then
        portage_profile_suffix="/instru-devel"
    elif [[ "${CURRENT_RECIPE_INSTRUMENTATION_LEVEL}" -ge 2 ]]; then
        portage_profile_suffix="/instru-debug"
    fi
fi
eselect profile set "${PORTAGE_PROFILE:-}${portage_profile_suffix}"

# vim: set ts=4 sts=4 sw=4 et ft=sh:
