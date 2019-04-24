.. Copyright © 2019 ANSSI.
   CLIP OS is a trademark of the French Republic.
   Content licensed under the Open License version 2.0 as published by Etalab
   (French task force for Open Data).

.. _update:

System updates
==============

Safe, convenient and regular updates are required to ensure that a CLIP OS
system is able to enforce and keep its security properties over time.

.. admonition:: Goal of this document
   :class: notice

   This document is a global description of the update model. Please see the
   `update client documentation
   <https://github.com/clipos/src_platform_updater>`_ for instructions on
   client configuration and server setup.

Requirements
------------

The following properties are required for the interaction between updates and
the local system (client side):

  * **Safe**: Updates must never interfere with the currently running system
    and must be safe to apply while the system is online and in use.
  * **In-background**: Updates should happen transparently to the user and in
    the background.
  * **Atomic**: Updates are either completely installed or not available as a
    choice during system boot. A system should always boot by default to a
    properly installed version and never into a partially updated system.
  * **Rollback**: If the newly updated system has issues, the user must be able
    to return temporarily to the previous version until a new update is
    available.

The following properties are required to control update deployments (server
side):

  * **Client identification**: Administrators must be able to identify requests
    for each client. This indirectly allows administrators to check for system
    usage and aliveness.
  * **Client version reporting**: Administrators must be able to identify which
    version is installed on each client.
  * **Update channels (alpha, beta, stable)**: Administrators must be able to
    progressively deploy an update to small groups of clients for live tests.

Threats considered
------------------

Here is a list of threat scenario considered and for which we would like to
protect the system from regarding the update process:

1. Compromised update server:

   * Has full control over the content served to the client.
   * Has no direct physical access to the system.
   * Does not have access to the update signing key.

2. Active man-in-the-middle attacker:

   * Has full control over the external network on which is connected the
     workstation.
   * Has no direct physical access to the system.
   * Does not have access to the update signing key.

3. Active local attacker:

   * Has full control over the external network on which is connected the
     workstation.
   * Has full physical access to the system.
   * Does not have access to the update signing key.

Implementation
--------------

CLIP OS systems have the following system layout:

  * UEFI boot only, following the `Boot Loader Specification
    <https://systemd.io/BOOT_LOADER_SPECIFICATION.html>`_.
  * A/B partition setup using Logical Volumes for system Read-Only partitions
    (for example: Core).
  * Single partition setup for stateful partitions.

Updating a CLIP OS system is equivalent to:

  * Downloading the latest Core partition and EFI binary from the update
    server.
  * Installing the Core partition in the currently unused Logical Volume or
    creating a new one if only one exists.
  * Installing the EFI binary with a name following the `Boot Loader
    Specification <https://systemd.io/BOOT_LOADER_SPECIFICATION.html>`_ and
    removing binaries associated with previous and now unavailable versions.
  * Rebooting the system to automatically boot the new version.

The requirements for the client are met with the following implementation:

  * **Safe**: Since updates are never applied onto files or partitions
    currently used by the running system, they can be performed without
    impacting the system integrity.
  * **In-background**: As updates do not impact the currently running system,
    they can performed in background without user interaction. They will only
    be effective after a reboot. There is no additional update process at
    shutdown/boot time.
  * **Atomic**: The system is either updated or not. Updates may be partially
    applied but the system will not see them and will always boot on the latest
    working version. Updates applied at the Logical Volume granularity for the
    system partition (Core).
  * **Rollback**: Two versions of the system are always available for user
    choice during boot. If the new system has critical bugs, the user may
    choose to revert to the previously working version until the next update.

The requirements for control applied on the server side are met with the
following implementation:

  * **Client identification**: Each request made by the client includes the
    system's current machine-id thus providing a unique and stable identifier.
  * **Client version reporting**: Each request made by the client includes the
    system's current version.
  * **Update channels (alpha, beta, stable)**: As version and identification
    are provided on each request, the server is able to decide which version to
    provide to each client.

    .. admonition:: Status
       :class: notice

       The server side implementation of update channels has not been
       implemented yet.

Security
~~~~~~~~

The update process security properties are implemented using the following
security features:

  * In transport confidentiality and integrity:

    * HTTPS using TLS 1.2 & 1.3 only.
    * Pinned Root Certificate Authority (requires an empty set of system
      certificates).

  * At rest integrity:

    * Each update payload is verified using a cryptographic signature produced
      by `minisign` / `rsign2`.

  * Rollback resistance (during update process):

    * Update payload versions are specified as trusted comment in the signature
      and are validated before the update is applied preventing an attacker
      from masquerading an old release as a new one.

Unaddressed threats and potential weaknesses
--------------------------------------------

* Offline rollback resistance: There is currently no protection against a local
  attacker replacing the currently installed version of the system by an older
  and valid version with direct disk access.

* Update signing key compromise: There is currently no mitigation strategy for
  a compromise of the update signing key.
