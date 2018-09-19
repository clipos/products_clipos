.. Copyright © 2018 ANSSI.
   CLIP OS is a trademark of the French Republic.
   Content licensed under the Open License version 2.0 as published by Etalab
   (French task force for Open Data).

Security objectives
===================

This is the list of all the security objectives we would like to achieve in the
CLIP OS project.

For the order and priority in which we will try achieve these objectives,
please check out the :ref:`project roadmap <roadmap>`.

Hardware requirements
---------------------

* x86-64 architecture (AMD64 / Intel 64)

* UEFI Secure Boot:

  * Removable default keys
  * Custom key enrollment available

* Trusted Platform Module (TPM):

  * Discrete TPM preferred, firmware TPM not recommended
  * Certified TPM preferred
  * Version 2.0 preferred, 1.2 accepted

Hypotheses
----------

* Hardware-based mechanisms and isolation are assumed trusted, properly
  functional and configured. Here is a non-exhaustive list of hardware-based
  security and isolation mechanisms:

  * UEFI firmware
  * Secure Boot
  * TPM
  * MMU
  * IOMMU
  * Hardware assisted virtualization

* Chosen cryptographic primitives are assumed robust.

Threat scenarios
----------------

Here is a list of threat scenario properties we consider and for which we would
like to protect the system from:

1. The remote attacker:

   * has full control over the external network on which is connected the
     workstation.
   * has no direct physical access to the system.

2. An untrusted user:

   * has full control over the external network.
   * owns valid credentials to access to a user session.

3. An untrusted administrator (i.e., with an *Administrator* role access):

   * has full control over the external network as well as the workstation
     network configuration (in whole or in parts).
   * owns valid credentials to access an administrator session.

4. Local attacker:

   * has full control over the external network.
   * has full access to the hardware (storage, TPM, firmware, etc.).

In more concrete and somewhat realistic terms, the above threat properties
would coincide with those types of threats:

* Theft of the workstation:

  * Confidentiality of the data stored is then guaranteed.

* "Evil maid" attacks:

  * The system integrity is guaranteed.

* Untrusted Web browsing or untrusted document opening:

  * The system integrity cannot be affected by any untrusted document or unsafe
    remote content.

Objectives
----------

Development model
~~~~~~~~~~~~~~~~~

Source code availability
^^^^^^^^^^^^^^^^^^^^^^^^

The entire project source tree is publicly hosted on GitHub and GitLab.

:Status: Completed
:Version: 5.0 alpha

Built from source
^^^^^^^^^^^^^^^^^

* The project is entirely built from source. This property is guaranteed by
  nightly clean builds of the entire project.

  :Status: In progress

* All-in-one source tree: the project source tree includes all the
  third-parties assets which are vendored within the source tree and versioned
  through Git and Git LFS.

  This property allows a developer to build any specific version of CLIP OS
  offline provided that the complete source tree has been downloaded with all
  the appropriate revisions for every sub-projects and provided that the CLIP
  OS toolkit runtime minimal requirements for that specific version have been
  met.

  This property also provides resiliency to the CLIP OS project: the
  availability of the source tree and its complete build ability is not
  affected by the availability of a third-party project on which the CLIP OS
  project depends.

  :Status: Completed
  :Version: 5.0 alpha

"Bit-exact" reproducible builds
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Final images are guaranteed to be identically reproducible (i.e., two images
resulted from two different builds processes with the exact same version and
parameter set have the same checksum).

This property provides the developer with a tamper detection method to ensure
that a given image (in whole or in part, e.g., for a specific recipe) has not
been tampered with and actually correspond to the build result of the claimed
version specification of the said image.

:Status: Not started

Source code integrity
^^^^^^^^^^^^^^^^^^^^^

The integrity of the project source code is guaranteed by the cryptographic
signature of every Git commit made by the CLIP OS project maintainers.

However, since the project makes use of lots of third-party source code, most
of the sources involved in the CLIP OS project cannot be part of the source
tree as such (i.e., as mirrored Git repositories under the ``src/external/``
directory). These third-party source code assets are thus provided as archive
files under one of the directories below ``assets/``.

The integrity of those third-party archive assets is guaranteed by the
verification of cryptographic hashes against known-good values from trusted
sources.

.. admonition:: Case of the Gentoo's *distfiles* and other Git LFS assets
   :class: note

   The source code tarballs, a.k.a. *distfiles*, referenced in the Gentoo
   ``ebuild`` files are used to build the application packages by Portage.

   The checksum values of those *distfiles* are provided by the ``Manifest``
   files within the Gentoo Portage tree. Since this tree is built with
   cryptographically signed Git commits from the Gentoo project developers, we
   can then assess both integrity and authenticity (by transitivity) of those
   *distfiles*.

   The same mechanism is true for the Gentoo *stage3* image and other vendored
   binary assets found under the ``assets/`` directory and which are stored
   through Git LFS. Since the Git LFS *pointer files* hold the SHA256 hash of
   the said files and since those *pointer files* are brought by PGP-signed Git
   commits from one of the CLIP OS project maintainers, we can therefore assess
   both the integrity and authenticity of those assets files.

.. admonition:: Exceptions to this principle
   :class: warning

   The exceptions of this principle concerns the closed-source firmwares for
   specific hardware, such as:

   * graphics adapters,
   * wireless network interface controllers,
   * Bluetooth controllers,
   * etc.

:Status: Completed
:Version: 5.0 alpha

Affordable customization
^^^^^^^^^^^^^^^^^^^^^^^^

* Efforts have been made to ensure the project can be customized and adapted to
  meet specific infrastructure or deployment requirements. As a consequence,
  creating a project based on CLIP OS should not require extensive changes to
  the project source files.

  :Status: First functional draft of the derivation mechanism
  :Version: 5.0 alpha

* Documentation and maintenance instructions are made available to allow
  third-parties to derive the CLIP OS project and guide them into maintaining
  their own version of CLIP OS derivatives.

  Please note though that these derivative projects cannot be named "CLIP OS"
  as "CLIP OS" is a trademark of the French Republic and its usage is exclusively
  reserved to the ANSSI.

  :Status: Not started

Build environment isolation
^^^^^^^^^^^^^^^^^^^^^^^^^^^

* The SDK environment used to build all software from source is logically
  isolated from the developer's system using Linux standard containers
  technologies (mainly namespaces). All recipes steps all executed in the SDK
  environment which is based on an immutable image with a statefull overlay
  that is discarded upon each steps completion.

  :Status: Completed
  :Version: 5.0 alpha

* Build steps isolation is enforced by the following Portage security features
  that are enabled in the Gentoo Hardened SDK used to compile the CLIP OS Core
  and EFIboot recipes:

  * ``sandbox``
  * ``userfetch``
  * ``userpriv``
  * ``usersandbox``

  See Portage's ``make.conf(5)`` man page on a Gentoo environment for details
  about each option.

  :Status: Completed
  :Version: 5.0 alpha

Usage of memory-safe languages
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Software written specifically for the project should use a memory-safe language
(for example: Rust, Go, Python, etc.). Exceptions should be justified.
Alternatives should be thought for software currently included in the project
but written in a memory-unsafe language.

:Status: In progress

Limit impact of security issues inherent to memory-unsafe languages
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* The Portage profiles used to build all software inside the CLIP OS *core* and
  *EFI boot* recipes are based on the Gentoo Hardened no-multilib profile. This
  guarantee that all executable are hardened at compile time.

  To reduce the attack surface, a custom set of USE flags are applied to limit
  the amount of features included by default.

  :Status: Completed
  :Version: 5.0 alpha

* The following Portage QA checks and features are enabled:

  * ``strict``
  * ``QA_STRICT_EXECSTACK="set"``
  * ``QA_STRICT_FLAGS_IGNORED="set"``
  * ``QA_STRICT_MULTILIB_PATHS="set"``
  * ``QA_STRICT_PRESTRIPPED="set"``
  * ``QA_STRICT_TEXTRELS="set"``
  * ``QA_STRICT_WX_LOAD="set"``

  See ``make.conf(5)`` man page on a Gentoo environment setup for details about
  each option.

  :Status: Completed
  :Version: 5.0 alpha

* The following Portage features should be enabled:

    * ``stricter``

  :Status: Not started

Content origin tracking
^^^^^^^^^^^^^^^^^^^^^^^

Gentoo's Portage allows us to keep track of each file included in the final
images. Each file can be either linked back to a specific package (and
therefore its source code through the ``ebuild`` specification of that package)
or linked back to a change made by a configuration step by examinating the
``configure`` action step of the concerned recipe (this step serve as a way to
operate fine tuning operations to recipe result files and which are found to be
tedious or impossible to integrate into ``ebuild`` packages).

:Status: Completed
:Version: 5.0 alpha


Core system properties
~~~~~~~~~~~~~~~~~~~~~~

Boot chain integrity
^^^^^^^^^^^^^^^^^^^^

* The integrity of the system boot chain is guaranteed by the combination of
  several security mechanisms:

  The initial bootloader is signed using UEFI Secure Boot.

  :Status: Completed
  :Version: 5.0 alpha

* The Linux kernel, initramfs and command line are packaged in a single file as
  an EFI binary signed using UEFI Secure Boot.

  :Status: Completed
  :Version: 5.0 alpha

* Firmware integrity, configuration, bootloader and kernel bundle binary
  integrity measurements are included in TPM based secret sealing operations.

  :Status: Not started

Unattended system bootup
^^^^^^^^^^^^^^^^^^^^^^^^

TPM secret sealing and unsealing for unattended system partition encryption and
decryption on bootup.

:Status: Not started

System on disk data integrity
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* Read only system program data and configuration is separated from writable
  system state and configuration using two distinct logical volumes partitions.

  The system root partition is a squashfs file system image mounted as read
  only. The squashfs image integrity is ensured by DM-Verity. The DM-Verity
  root hash is included in the kernel command line, which is protected by
  Secure Boot.

  :Status: Completed
  :Version: 5.0 alpha

* The writable system state partition integrity is ensured by DM-Integrity. The
  secret used to unlock the DM-Integrity partition is sealed using the TPM.

  :Status: Not started

System on disk data confidentiality
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* The writable system state partition confidentiality is insured by DM-Crypt.
  The secret used to unlock the DM-Crypt partition is sealed using the TPM.

  :Status: Not started

* The system root partition confidentiality may be insured by DM-Crypt. The
  secret used to unlock the DM-Crypt partition is sealed using the TPM.

  :Status: Not started

* In order to allow recovery of the encrypted system partitions by an
  administrator, an additional LUKS key slot is provisioned. This allows
  offline secret escrow during system install phase.

  :Status: Not started

Arbitrary code execution restrictions (W^X, a.k.a. Write XOR Execute)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* Hardware and kernel level enforcement of the exclusion of write and execute
  permissions on memory regions.

  Please refer to the :ref:`kernel` page for details.

  :Status: In progress

* System-wide enforcement of the write and execute permissions exclusion
  principle:

  * The system root partition contains executable files and is thus
    read-only.
  * The system stateful partition is writable and is thus mounted with the
    ``noexec`` option.

  :Status: In progress

* Interactive interpreters (Bash, Python, etc.) shall refuse to execute code
  from writable filesystems.

  :Status: Not started

System administration roles separation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* Limited trust in ``root`` user.

  :Status: Not started

* Constrained administrator role.

  :Status: Not started

* Auditor role.

  :Status: Not started

* No privilege elevation mechanism support:

  * No SUID binaries, SUID binaries disabled, all partitions mounted with the
    ``nosuid`` mount option.
  * Capability bounding sets
  * No new privileges flag (``no_new_privs``) set for the PID 1 process.

  :Status: In progress

System and user authentication separation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Storage space for system and user authentication secrets are separated.

:Status: Not started

Non-persistency of eventual system or user session compromise
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* Privileged user (i.e., ``root``) level compromises are mitigated against
  persistency methods which make use of the filesystem. Such compromises would
  have their lifecycles limited to system boot lifetime (uptime).

  :Status: In progress

* Unprivileged user level (i.e., the current user) compromises are mitigated
  against persistency methods which make use of the filesystem. Such
  compromises would have their lifecycles limited to the compromised user
  session lifetime.

  :Status: Not started

Journaling
^^^^^^^^^^

* "Append-mostly" log storage and automatic rotation using
  ``systemd-journald``.

  :Status: Completed
  :Version: 5.0 alpha

* Append-only log storage and automatic log rotation.

  :Status: Not started

* Log forwarding to remote storage.

  :Status: Not started

Robust update system
^^^^^^^^^^^^^^^^^^^^

* Atomic, in-background and non-intrusive upgrade mechanism using A/B
  partitions (similar to Android or ChromeOS).

  :Status: In progress

* Fallback version available in case of unpredicted failure or bug.

  :Status: In progress

* Supports updating both the system and other environments.

  :Status: Not started

* Update transport protection.

  :Status: In progress

* Detailed update signature key compromise impact.

  :Status: Not started

* Rollback protection.

  :Status: Not started

Remote attestation
^^^^^^^^^^^^^^^^^^

Remote version, configuration and system state attestation using the TPM.

:Status: Not started

Linux kernel confidentiality
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The initial EFI boot binaries must reside in clear text on the disk to allow
automatic system startup. If kernel image confidentiality protection is
required, an additional kernel image and initramfs will be stored inside the
encrypted system partition. The initial initramfs will thus kexec the new
kernel and initramfs during boot time.

:Status: Not started

Linux kernel provided security
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Please refer to the :ref:`kernel` page for details.

Linux kernel hardening
^^^^^^^^^^^^^^^^^^^^^^

* Please refer to the :ref:`kernel` page for details.

* The kernel is carefully configured and only strictly required options are
  enabled. Each rationale behind those options is documented.

  Hardware support uses kernel modules which are loaded following tailored
  profiles (per hardware platform). Kernel modules loading is disabled at a
  very early stage of the system startup once the system is considered booted
  and shall not require any additional kernel module later on.

  The kernel protects itself from attacks originating from userspace (``root``
  user included).

  :Status: In progress

Full sub-environment isolation using hardware-assisted virtualization
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* Support for KVM based virtualization and paravirtualized drivers only
  (i.e., ``virtio`` drivers).

  :Status: Not started

* Minimal QEMU configuration.

  :Status: Not started

* QEMU process instances are confined.

  :Status: Not started

* Alternative system virtualizer as a replacement for QEMU (nemu, crosvm,
  etc.).

  :Status: Not started

Safe operation of untrusted filesystem
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* FUSE-based userspace mount of untrusted file systems.

  :Status: Not started

* Virtual machine-based in-kernel mounting and sharing using NFS, CIFS, 9P,
  etc.

  :Status: Not started

Network setup, isolation and access control
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* Automatic and manual network configuration.

  :Status: Not started

* Automatic IPsec tunnel setup once network access is configured.

  :Status: Not started

* Access control, isolation and IPSec usage enforcement for host and
  environments.

  :Status: Not started

Multi-level environment
^^^^^^^^^^^^^^^^^^^^^^^

* Host and sub-environment service and application isolation using Linux
  namespaces, cgroups, seccomp-bpf filters, etc.

  :Status: In progress

* Multi-level enforcement using an LSM inspired from Vserver.

  :Status: Not started

* Configurable sub environments restrictions and network access.

  :Status: Not started

* Safe and controlled communication to the host:

  * Unix sockets or encrypted TCP sockets (SSH)
  * vsocks (virtio)

  :Status: Not started

* Host controlled inter-level communication:

  * File passing diode
  * Encrypting / decryption diode
  * Smartcard proxy and command filtering (see *Caml Crush* project)

  :Status: Not started

* Intra-level application isolation using Flatpak.

  :Status: Not started

Remote administration and fleet management
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

:Status: Not started

Automatic provisioning and installation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

:Status: Not started

Safe recovery mode for backup and administration performed recovery
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

:Status: Not started

Mandatory Access Control
^^^^^^^^^^^^^^^^^^^^^^^^

:Status: Not started

Certification and Common Criteria Evaluation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

:Status: Not started

User-related properties
~~~~~~~~~~~~~~~~~~~~~~~

User data confidentiality and integrity
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* User data partition protected by DM-Crypt + DM-Integrity with a user provided
  secret.

  :Status: Not started

* User storage partition unlocking with password.

  :Status: Not started

* User storage partition unlocking with smartcard.

  :Status: Not started

* User storage partition unlocking with a security token (e.g., U2F/FIDO).

  :Status: Suggested, implementation not yet assessed

Device access control
^^^^^^^^^^^^^^^^^^^^^

* Device whitelisting.

  :Status: Not started

* Multi-level aware device assignation.

  :Status: Not started

* USB device management (e.g., USBGuard).

  :Status: Suggested, implementation not yet assessed

Graphical interface properties
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Trusted graphical interface
^^^^^^^^^^^^^^^^^^^^^^^^^^^

* Root compositor.

  :Status: Not started

* Wayland protocol based environment.

  :Status: Not started

* Trusted graphical components and display (trusted panel).

  :Status: Not started

* Protected lock-screen.

  :Status: Not started

* Protected input.

  :Status: Not started

Restricted users
^^^^^^^^^^^^^^^^

:Status: Not started

Application access control
^^^^^^^^^^^^^^^^^^^^^^^^^^

:Status: Not started

Deployment profiles
~~~~~~~~~~~~~~~~~~~

Here is the list of the considered deployment profiles for the CLIP OS images:

* Desktop environment
* Administrator dedicated environment
* Server environment

Assets summary
--------------

Here is a list of all the assets to protect with their protection level:

.. csv-table::
   :header: "Asset", "Integrity", "Confidentiality", "Availability"
   :widths: 5, 1, 1, 1

   "Bootloader code", "|yes|", "|no|", "|yes|"
   "Bootloader configuration", "|yes|", "|no|", "|yes|"

   "Linux kernel binary", "|yes|", "|no|", "|yes|"
   "Initramfs", "|yes|", "|no|", "|yes|"
   "Linux kernel command line [#cmdline]_", "|yes|", "|no|", "|yes|"

   "Linux kernel in-memory code and data", "|yes|", "|yes|", "|yes|"
   "Applications in-memory code and data", "|yes|", "|yes|", "|no|"

   "System application binaries", "|yes|", "|no|", "|yes|"
   "System application resources", "|yes|", "|no|", "|yes|"
   "System application configuration", "|yes|", "|yes|", "|yes|"
   "System authentication secrets", "|yes|", "|yes|", "|yes|"

   "User application binaries", "|yes|", "|no|", "|no|"
   "User application resources", "|yes|", "|no|", "|no|"
   "User application configuration", "|yes|", "|yes|", "|no|"
   "User authentication secrets", "|yes|", "|yes|", "|yes|"

.. |yes| unicode:: 0x2714 .. YES
.. |no| unicode:: 0x2718 .. NO

.. [#cmdline] The Linux kernel command line holds the DM-Verity root hash of
              the system partition.

.. vim: set tw=79 ts=2 sts=2 sw=2 et:
