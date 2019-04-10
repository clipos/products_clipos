#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017 ANSSI. All rights reserved.

# Portage configuration to be done each time a CLIP OS SDK is spawn.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${CURRENT_SDK_PRODUCT}/${CURRENT_SDK_RECIPE}/scripts/prelude.sh

sdk_info "Setting up Portage configuration for profile ${PORTAGE_PROFILE}..."

# Needed to get EMERGE_INTELLIGIBLE_OPTS:
source "${CURRENT_SDK}/scripts/emergeopts.sh"

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

# Delete configuration values that we are going to overwrite
portage_vars_to_delete=(
    # PORTDIR is erased from make.conf because the Portage tree directory path
    # is left for the default defined in /etc/portage/repos.conf
    PORTDIR

    # ACCEPT_LICENSE is erased from make.conf because we manage this setting
    # using special files in overlay profiles (see package.license.global and
    # the notice about Portage profile workaround below).
    ACCEPT_LICENSE

    # Rewritten by ourselves below:
    DISTDIR
    PKGDIR
    PORT_LOGDIR
    BINPKG_COMPRESS
    BINPKG_COMPRESS_FLAGS
    FEATURES
    MAKEOPTS
    EMERGE_DEFAULT_OPTS
    LINGUAS
    L10N
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

# The Portage FEATURES we want to use (see make.conf(5) for the reference of
# those):
wanted_portage_features=(
    # Ebuilds build isolation:
    sandbox
    userfetch  # ensure portage:portage privileges are used when "fetching"
    userpriv usersandbox  # build in sandbox as portage:portage (not root:root)
    cgroup  # gather all the build subprocess in a cgroup for Portage to safely kill them (if needed)
    #ipc-sandbox mount-sandbox network-sandbox pid-sandbox
    # TODO: If we decide to make use of user namespaces in cosmk for the SDK
    # container, then we may decide to use *-sandbox FEATURES in order to
    # isolate the ebuild-triggered subprocessed in dedicated namespaces.
    # In the current state (Apr. 2019), it is still not possible since unshare
    # syscall get a EPERM error as the SDK container does not have the
    # capability to create new namespaces.

    # Strip things we do not want in the targets we build:
    nodoc noinfo noman

    # Q/A settings:
    strict unknown-features-warn
    # TODO: Enable 'stricter' portage FEATURE (disabled due to QA failures).

    # Parallelization:
    # Note: "ebuild-locks" is absolutely required and sets a lock for
    # unsandboxed (e.g. pkg_setup, pkg_postinst, etc.) parts of the ebuilds:
    parallel-fetch parallel-install ebuild-locks
    # TODO: Should we disable 'parallel-install' for production builds?

    # Logging-related settings:
    split-elog split-log

    # Binary packages related settings:
    #binpkg-multi-instance
    # TODO: With a reorganization of the cache/ directory and with a proper
    # patch to Portage to ignore the environment variables populated by cosmk
    # in the SDK containers (i.e. the CURRENT_* environment variables), we may
    # make use of the binpkg-multi-instance FEATURE in order to share the
    # binary packages accross different recipes (i.e. a package built for
    # clipos/core could be reused in clipos/efiboot both contexts share the
    # same parameters for that package).
    # TODO: Once we have a CI, we should add 'getbinpkg' to FEATURES. Or should
    # we?

    # Miscellaneous settings:
    -news
)

# Build the main Portage configuration file for runtime:
cat <<EOF >> /etc/portage/make.conf

# Common location settings for Portage:
DISTDIR='/mnt/assets/distfiles'
PKGDIR='${CURRENT_CACHE_PKG}'
PORT_LOGDIR='${CURRENT_CACHE}/log'

# Binary packages compression settings:
BINPKG_COMPRESS='lz4'
BINPKG_COMPRESS_FLAGS='-1'

# Portage FEATURES (see make.conf(5) for the reference of those):
FEATURES='${wanted_portage_features[@]}'

# Build multithreading settings:
MAKEOPTS='-j ${make_jobs}'
EMERGE_DEFAULT_OPTS='--jobs ${emerge_jobs} ${EMERGE_INTELLIGIBLE_OPTS}'

# Locale and language-related settings:
LINGUAS="${LOCALE%_*} ${LOCALE%.*}"
L10N="${LOCALE%_*} ${L10N_LOCALE%.*}"

# Portage Q/A enforcement (see make.conf(5) for their meaning)
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

# Portage profile workaround for package.{,un}mask & package.license:
#
# This workaround on the Portage tree profiles is a hack to be able to declare
# files that are explicitly not managed by the Portage profiles (see the
# Package Manager Specification (aka. PMS) and related man pages or wiki pages:
# https://wiki.gentoo.org/wiki/Profile_(Portage) and
# https://wiki.gentoo.org/wiki//etc/portage for more details).

# Retrieve the Portage profiles inheritance list. This list is ordered
# bottom-up, i.e. from the deepest Portage profile (i.e. the least significant)
# to the Portage profile currently set:
portage_profile_parents_list="$(python -c 'import portage; print("\n".join(portage.config().profiles))'))"
readarray -t portage_profile_parents <<< "${portage_profile_parents_list}"

# List of candidate files for symlink creation into /etc/profile:
portage_profile_global_items=(
    # package.{,un}mask files in /etc/portage supports the masking per Portage
    # overlay (e.g. <category>/<package>::gentoo), which is not the case when
    # those files are set in the Portage tree overlays
    package.mask
    package.unmask
    # The package licenses set to accept can only be set in /etc/portage and
    # not in the Portage profiles
    package.license
)

# Set nullglob to handle empty directories
shopt -s nullglob

# Iterate on profile dependencies and create a symlink for each profile
# "global-override" files to the corresponding folder in /etc/portage
for profile_path in "${portage_profile_parents[@]}"; do
    for item in "${portage_profile_global_items[@]}"; do
        item_dir="${profile_path}/${item}.global-override"
        if [[ -d "${item_dir}" ]]; then
            mkdir -p "/etc/portage/${item}"
            for f in "${item_dir}/"*; do
                # Ignore README* files
                if [[ "$(basename "${f}")" =~ ^README ]]; then
                    continue
                fi
                ln -snf "${f}" "/etc/portage/${item}/$(basename "${f}")"
            done
            unset f
        elif [[ -e "${item_dir}" ]]; then
            die "Only directories are supported as .global-override items"
        fi
        unset item_dir
    done
    unset item
done
unset profile_path

# Display the final global override setup for debugging purposes:
msg="Setting up Portage profile global overrides (Portage configuration enforcement in /etc/portage directories):"
for item in "${portage_profile_global_items[@]}"; do
    item_dir="/etc/portage/${item}"
    if [[ -d "${item_dir}" ]]; then
        msg+=$'\n'"  * ${item_dir}/"
        for symlink in "${item_dir}/"*; do
            real_path="$(realpath "${symlink}")"
            msg+=$'\n'"    - ${symlink##*/} -> ${real_path#/mnt/}"
        done
        unset symlink
    fi
    unset item_dir
done
unset item
sdk_info "$msg"
unset msg

# vim: set ts=4 sts=4 sw=4 et ft=sh:
