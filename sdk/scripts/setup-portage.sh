#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017 ANSSI. All rights reserved.

# Portage configuration to be done each time a CLIP OS SDK is spawn.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${CURRENT_SDK_PRODUCT}/${CURRENT_SDK_RECIPE}/scripts/prelude.sh

# Needed to get EMERGE_INTELLIGIBLE_OPTS:
source "${CURRENT_SDK}/scripts/emergeopts.sh"

sdk_info "Setting up custom local Portage configuration..."

# Compute optimal values for the number of jobs to allocate for make and
# emerge. Since we throttle the amount of CPU shares dedicated to the current
# SDK container, let's assume we can use all the CPU capacity available to us.
# _NPROCESSORS_ONLN still reports the real physical number of CPUs of the
# underlying machine (even if the CPU share is constrained by the container).
nproc="$(getconf _NPROCESSORS_ONLN)"  # more portable than nproc
make_jobs="$((${nproc} + 1))"  # + 1 for the main thread of make
emerge_jobs="${nproc}"

# Set default LOCALE with fallback to 'en_US' if property is not defined
# Guess language to use from the locale defined in the product properties:
system_locale="${CURRENT_PRODUCT_PROPERTY['system.locale']:-'en_US.UTF-8'}"
locale_regionalized_language="${system_locale%%.*}"    # e.g. "en_US"
locale_regionless_language="${locale_regionalized_language%%_*}"   # e.g. "en"

# Drop all the pre-exisiting Portage configuration (i.e. the one that comes
# with the Gentoo stage3) but backup it rather than deleting it (just in case
# something new and important appears one day in that stage3 configuration so
# we can see what's missing in *our* configuration):
if [[ ! -e "/etc/.portage.original-from-stage3" ]]; then
    cp -a "/etc/portage" "/etc/.portage.original-from-stage3"
fi
find /etc/portage -mindepth 1 -delete   # delete contents but preserving parent dir

# The Portage FEATURES we want to use (see make.conf(5) for futher reference of
# those) and which ONLY affect the behavior of "emerge" and Portage in general
# (e.g. Q/A checks on packages production/building process, Portage sandboxing
# parameters while building, management of binary packages, and so on...).
# FEATURES that affect the result of the packages to be installed **MUST NOT**
# be declared here. Those FEATURES are to be declared in the Portage profiles
# in the Portage tree overlays instead (see the file
# profiles/clipos/amd64/make.defaults in the CLIP OS Portage tree overlay for
# an example).
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
cat <<EOF > /etc/portage/make.conf
#
# Dynamic Portage configuration file generated for this SDK instance by the
# SDK prelude script "setup-portage.sh".
#
# Important note: Do not declare here ACCEPT_LICENSE as this piece of
# configuration is managed by using special files in our overlay profiles (see
# "package.license.global-override" and the notice about Portage profile
# workaround in the "setup-portage.sh" file).
#

# Common location settings for Portage:
DISTDIR='/mnt/assets/distfiles'
PKGDIR='${CURRENT_CACHE_PKG}'
PORT_LOGDIR='${CURRENT_CACHE}/log'

# Binary packages compression settings:
BINPKG_COMPRESS='lz4'
BINPKG_COMPRESS_FLAGS='-1'

# Portage FEATURES that only affects the behavior of Portage and not the
# "emerged" results:
FEATURES='${wanted_portage_features[@]}'

# Build multithreading settings:
MAKEOPTS='-j ${make_jobs}'
EMERGE_DEFAULT_OPTS='--jobs ${emerge_jobs} ${EMERGE_INTELLIGIBLE_OPTS}'

# Locale and language-related settings:
L10N="${locale_regionless_language} ${locale_regionalized_language//_/-}"

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
declare -A portage_overlay_paths
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

    portage_overlay_paths["${reponame}"]="${repo}"
done
readonly portage_overlay_paths

# Set the Portage profile "vanilla" before considering instrumentation features
sdk_info "Portage profile to be used: \"${PORTAGE_PROFILE:?}\"."
eselect profile set "${PORTAGE_PROFILE}"
readonly main_profile_path="$(readlink -f "/etc/portage/make.profile")"
if [[ -n "${CURRENT_INSTRUMENTATION_FEATURES:-}" ]]; then
    rm -f "/etc/portage/make.profile"
    mkdir "/etc/portage/make.profile"
    cat <<EOF > "/etc/portage/make.profile/parent"
# DO NOT EDIT. This custom and artificial profile has been automatically
# generated by the "setup-portage.sh" script at launch of this SDK container.
# This is intended to enhance the current chosen profile (i.e. the first one
# in the list) with instrumentation "parts-of-profiles".

${main_profile_path}
EOF

    # Build up a message to inform the user that we inject parts of Portage
    # profile for instrumentation features:
    msg="INSTRUMENTED BUILD: Setting up an hybrid Portage profile with parts of Portage profile for instrumentation onto the Portage profile to use:"

    for overlay in ${PORTAGE_OVERLAYS}; do
        [[ "${overlay}" == "gentoo" ]] && continue   # skip Gentoo base overlay
        overlay_path="${portage_overlay_paths["${overlay}"]}"
        for instrufeat in ${CURRENT_INSTRUMENTATION_FEATURES}; do
            if [[ -d "${overlay_path}/profiles/instrumentation/${instrufeat}" ]]; then
                echo "${overlay_path}/profiles/instrumentation/${instrufeat}" >> "/etc/portage/make.profile/parent"
                msg+=$'\n'"  * ${overlay_path#/mnt/}/profiles/instrumentation/${instrufeat}"
            fi
        done
    done

    for instrufeat in ${CURRENT_INSTRUMENTATION_FEATURES}; do
        if [[ -d "${main_profile_path}/instrumentation/${instrufeat}" ]]; then
            echo "${main_profile_path}/instrumentation/${instrufeat}" >> "/etc/portage/make.profile/parent"
            msg+=$'\n'"  * ${main_profile_path#/mnt/}/instrumentation/${instrufeat}"
        fi
    done

    sdk_warn "$msg"
    unset overlay overlay_path instrufeat msg
fi

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
if [[ "${portage_profile_parents[-1]}" == "/etc/portage/make.profile" ]]; then
    # strip it from the list as it is not a real profile from Portage trees
    unset portage_profile_parents[-1]
fi

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
