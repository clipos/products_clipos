# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017-2018 ANSSI. All rights reserved.

# CLIP core SDK emerge options and utility functions

# Options to make the emerge more comprehensive and verbose for interesting
# things. This eases debugging for developers.
#
# This is appended to the EMERGE_DEFAULT_OPTS of the Portage configuration by
# the SDK entrypoint script.
emerge_intelligible_optarray=(
    # Tree output with the dependency order (rather than the emerging order) is
    # far more comprehensible than the default output.
    --tree --unordered-display

    # Be verbose on what emerge is about to do, merge and explain in details
    # when a conflict appears or if a package must be rebuild due to a new
    # slot.
    --verbose --verbose-conflicts --verbose-slot-rebuilds=y

    # But do not pollute the standard output with the complete build log of a
    # package if this one fails to build (logs are stored in a directory
    # volume-bound in the host anyway).
    --quiet-build
)
readonly EMERGE_INTELLIGIBLE_OPTS="${emerge_intelligible_optarray[@]}"


# The emerge options to be used by the "build" action in charge of emerging
# (or updating) packages from source in a detached ROOT.
#
# IMPORTANT WARNING: Do not put the "--deep" option in the follwing option set.
# The "--deep" option will prevent most of the time the emerge in a detached
# ROOT which is intended to have a different profile than the SDK. This is
# explained by the fact that emerge is going to dig too deep in the dependency
# graph (actually more than necessary to build the target in ROOT [1]) and will
# therefore want to change packages necessary only to the SDK (whose
# recompilations are utterly useless since the spawned SDK container is
# ephemeral) and which might not affect the way the packages will be compiled
# in ROOT. Note that I am not implying that any of the packages in the SDK do
# not need rebuild, only that a part of them are not necessary to rebuild for
# the proper build of ROOT's packages and those can trigger awful conflicts to
# be fixed for zero interest.
# To be honest, chances are that you are going to need to recompile some
# packages of the SDK to properly build the packages of ROOT, and this is fine.
# Some of them will even trigger conflicts due to cyclic dependency to be
# broken by hand. This is left to be fixed on a case-by-case basis in the
# target build scripts launched in the SDK.
#
# [1]: As things stand currently, it is not possible (yet?) to tell emerge to
# go "--deep" in the dependency graph (essentially to ensure that every package
# is up-to-date in ROOT against the Portage overlays configuration that might
# have changed) with the limitation to the packages belonging to ROOT only
# (with ROOT different from "/" obviously).
emerge_buildrootwithbdeps_optarray=(
    # Rebuild a package if it happens to come from another Portage tree overlay
    # than the one already available (even if both specifications match).
    --newrepo

    # If a package specification has a changed USE flag supported set (IUSE
    # set) or if the USE flag switches for this package have changed, then
    # reconsider it.
    --newuse

    # If a package specification has a changed dependency list (RDEPEND), then
    # reconsider it.
    # Consider also the build dependencies (DEPEND) in this comparision (this
    # also implies the build dependencies for the comparision in the binary
    # packages done by the option --binpkg-checked-deps=y).
    --changed-deps --with-bdeps=y

    # Always build binary pacakges during build action
    --buildpkg=y

    # Use binary package to speed up builds...
    --usepkg=y
    # ...but do not consider the binary package if the requested package
    # specification has slightly changed from the available binary package.
    # These are defaults anyway but let's assert the two options controlling
    # this:

    # Do not install a binary package if its dependency set has changed between
    # the binary package and the ebuild.
    --binpkg-changed-deps=y

    # Do not install a binary package if its USE flags settings do not match
    # those we want.
    --binpkg-respect-use=y

    # If a build-dependency is to be rebuilt, then rebuild also the packages on
    # which they depdend. Be careful on this option since it may retrigger
    # rebuild of a lot of packages.
    # TODO: investigate, is it too broad? we can also consider as a replacement
    # the options --rebuild-if-new-rev=y or --rebuild-if-new-ver=y
    --rebuild-if-unbuilt=y

    # If a new slot can satisfy a dependency (in the sense of the atom
    # comparision operators), then rebuild this package (with the dependency
    # with the newer slot).
    # TODO: investigate, is it really necessary? why?
    --rebuild-if-new-slot=y

    # Update packages during incremental builds.
    # TODO: investigate, does it properly work?
    --update
)
readonly EMERGE_BUILDROOTWITHBDEPS_OPTS="${emerge_buildrootwithbdeps_optarray[@]}"


# The emerge options to be used by the "image" action in charge of emerging
# (or updating) packages from *binary packages ONLY* in a detached ROOT.
emerge_imagerootonlyrdeps_optarray=(
    # Only use the binary packages (which have been produced previously with
    # the "build" action thanks to the EMERGE_BUILDROOTWITHBDEPS_OPTS). If a
    # package or a runtime dependency is missing, voluntarily fail the emerge.
    --usepkgonly=y

    # We do not want to pull build dependencies as this is left to the "build"
    # action part. We do not even consider them even if they have changed since
    # it is none of the buisness of the "image" action.
    # Only the runtime dependencies (RDEPENDS) will be checked.
    --with-bdeps=n

    # Do not install a binary package if its USE flags settings do not match
    # those we want.
    --binpkg-respect-use=y

    # Do not install a binary package if its dependency set (*binary*
    # dependency set because of the options --with-bdeps=n) has changed between
    # the binary package and the ebuild.
    --binpkg-changed-deps=y

    # Do not consider anything that is not in ROOT.
    --root-deps=rdeps
)
readonly EMERGE_IMAGEROOTONLYRDEPS_OPTS="${emerge_imagerootonlyrdeps_optarray[@]}"

# vim: set ts=4 sts=4 sw=4 et ft=sh:
