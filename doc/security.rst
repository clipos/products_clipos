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

.. admonition:: Status
   :class: tip

   Completed in version **5.0 alpha**.

Built from source
^^^^^^^^^^^^^^^^^

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

  .. admonition:: Status
     :class: tip

     Completed in version **5.0 alpha**.

* The project is entirely built from source. This property is guaranteed by
  nightly clean builds of the entire project.

  .. admonition:: Status
     :class: notice

     In progress:

     * Basic CI infrastrucure is operational.
     * Build results are not yet publicly available.

"Bit-exact" reproducible builds
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Final images are guaranteed to be identically reproducible (i.e., two images
resulted from two different builds processes with the exact same version and
parameter set have the same checksum).

This property provides the developer with a tamper detection method to ensure
that a given image (in whole or in part, e.g., for a specific recipe) has not
been tampered with and actually correspond to the build result of the claimed
version specification of the said image.

.. admonition:: Status
   :class: warning

   Not started.

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

.. admonition:: Status
   :class: tip

   Completed in version **5.0 alpha**.

Affordable customization
^^^^^^^^^^^^^^^^^^^^^^^^

* Efforts have been made to ensure the project can be customized and adapted to
  meet specific infrastructure or deployment requirements. As a consequence,
  creating a project based on CLIP OS should not require extensive changes to
  the project source files.

  .. admonition:: Status
     :class: tip

     First functional draft of the derivation mechanism completed in version
     **5.0 alpha**.

* Documentation and maintenance instructions are made available to allow
  third-parties to derive the CLIP OS project and guide them into maintaining
  their own version of CLIP OS derivatives.

  Please note though that these derivative projects cannot be named "CLIP OS"
  as "CLIP OS" is a trademark of the French Republic and its usage is exclusively
  reserved to the ANSSI.

  .. admonition:: Status
     :class: warning

     Not started.

Build environment isolation
^^^^^^^^^^^^^^^^^^^^^^^^^^^

* The SDK environment used to build all software from source is logically
  isolated from the developer's system using Linux standard containers
  technologies (mainly namespaces). All recipes steps all executed in the SDK
  environment which is based on an immutable image with a statefull overlay
  that is discarded upon each steps completion.

  .. admonition:: Status
     :class: tip

     Completed in version **5.0 alpha**.

* Build steps isolation is enforced by the following Portage security features
  that are enabled in the Gentoo Hardened SDK used to compile the CLIP OS Core
  and EFIboot recipes:

  * ``sandbox``
  * ``userfetch``
  * ``userpriv``
  * ``usersandbox``

  See Portage's ``make.conf(5)`` man page on a Gentoo environment for details
  about each option.

  .. admonition:: Status
     :class: tip

     Completed in version **5.0 alpha**.

Usage of memory-safe languages
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Software written specifically for the project should use a memory-safe language
(for example: Rust, Go, Python, etc.). Exceptions should be justified.
Alternatives should be thought for software currently included in the project
but written in a memory-unsafe language.

.. admonition:: Status
   :class: notice

   In progress.

Limit impact of security issues inherent to memory-unsafe languages
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* The Portage profiles used to build all software inside the CLIP OS *core* and
  *EFI boot* recipes are based on the Gentoo Hardened no-multilib profile. This
  guarantee that all executable are hardened at compile time.

  To reduce the attack surface, a custom set of USE flags are applied to limit
  the amount of features included by default.

  .. admonition:: Status
     :class: tip

     Completed in version **5.0 alpha**.

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

  .. admonition:: Status
     :class: tip

     Completed in version **5.0 alpha**.

* The following Portage features should be enabled:

    * ``stricter``

  .. admonition:: Status
     :class: warning

     Not started.

Content origin tracking
^^^^^^^^^^^^^^^^^^^^^^^

Gentoo's Portage allows us to keep track of each file included in the final
images. Each file can be either linked back to a specific package (and
therefore its source code through the ``ebuild`` specification of that package)
or linked back to a change made by a configuration step by examinating the
``configure`` action step of the concerned recipe (this step serve as a way to
operate fine tuning operations to recipe result files and which are found to be
tedious or impossible to integrate into ``ebuild`` packages).

.. admonition:: Status
   :class: tip

   Completed in version **5.0 alpha**.


Core system properties
~~~~~~~~~~~~~~~~~~~~~~

Boot chain integrity
^^^^^^^^^^^^^^^^^^^^

* The integrity of the system boot chain is guaranteed by the combination of
  several security mechanisms:

  The initial bootloader is signed using UEFI Secure Boot.

  .. admonition:: Status
     :class: tip

     Completed in version **5.0 alpha**.

* The Linux kernel, initramfs and command line are packaged in a single file as
  an EFI binary signed using UEFI Secure Boot.

  .. admonition:: Status
     :class: tip

     Completed in version **5.0 alpha**.

* Firmware integrity, configuration, bootloader and kernel bundle binary
  integrity measurements are included in TPM based secret sealing operations.

  .. admonition:: Status
     :class: notice

     In progress:

     * Firmware integrity and configuration (includes Secure Boot setup)
       measurements are included in TPM based secret sealing operations.
     * Bootloader and kernel bundle binary measurements are currently ignored.

Unattended system bootup
^^^^^^^^^^^^^^^^^^^^^^^^

* TPM secret sealing and unsealing for unattended system partition encryption
  and decryption on bootup.

.. admonition:: Status
   :class: tip

   Completed in version **5.0 beta** (`clipos/bugs#8
   <https://github.com/clipos/bugs/issues/8>`_).

* Additional enhancements:

  * Additional tests with real hardware.
  * Kernel keyring (``keyctl``) support.
  * Improved installation and initial setup support.

.. admonition:: Status
   :class: warning

   Not started (`clipos/bugs#22 <https://github.com/clipos/bugs/issues/22>`_).

System on disk data integrity
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* Read only system program data and configuration is separated from writable
  system state and configuration using two distinct logical volumes partitions.

  The system root partition is a squashfs file system image mounted as read
  only. The squashfs image integrity is ensured by DM-Verity. The DM-Verity
  root hash is included in the kernel command line, which is protected by
  Secure Boot.

  .. admonition:: Status
     :class: tip

     Completed in version **5.0 alpha**.

* The writable system state partition integrity is ensured by DM-Integrity. The
  secret used to unlock the DM-Integrity partition is sealed using the TPM.

  .. admonition:: Status
     :class: warning

     Not started.

System on disk data confidentiality
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* The writable system state partition confidentiality is insured by DM-Crypt.
  The secret used to unlock the DM-Crypt partition is sealed using the TPM.

  .. admonition:: Status
     :class: tip

     Completed in version **5.0 beta** (`clipos/bugs#8
     <https://github.com/clipos/bugs/issues/8>`_).

* The system root partition confidentiality may be insured by DM-Crypt. The
  secret used to unlock the DM-Crypt partition is sealed using the TPM.

  .. admonition:: Status
     :class: warning

     Not started.

* In order to allow recovery of the encrypted system partitions by an
  administrator, an additional LUKS key slot is provisioned. This allows
  offline secret escrow during system install phase.

  .. admonition:: Status
     :class: warning

     Not started.

Arbitrary code execution restrictions (W^X, a.k.a. Write XOR Execute)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* Hardware and kernel level enforcement of the exclusion of write and execute
  permissions on memory regions.

  .. admonition:: Status
     :class: notice

     In progress. Please refer to the :ref:`kernel` page for details.

* System-wide enforcement of the write and execute permissions exclusion
  principle:

  * Applications code is stored in a read only partition.
  * Execution of code from writable partitions is denied.

  .. admonition:: Status
     :class: notice

     In progress. Status as of version **5.0 beta**:

     * System root partition is read-only (Squashfs and DM-Verity).
     * All writable partitions are mounted with the ``noexec`` option.

* Interactive interpreters (Bash, Python, etc.) shall refuse to execute code
  from writable filesystems.

  .. admonition:: Status
     :class: warning

     Not started.

System administration roles separation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* Limited trust in ``root`` user.

  .. admonition:: Status
     :class: warning

     Not started.

* Constrained administrator (admin) role.

  .. admonition:: Status
     :class: notice

     In progress. Initial support available in versions **5.0 beta**
     (`clipos/bugs#17 <https://github.com/clipos/bugs/issues/17>`_).

* Auditor (audit) role.

  .. admonition:: Status
     :class: notice

     In progress. Initial support available in versions **5.0 beta**
     (`clipos/bugs#17 <https://github.com/clipos/bugs/issues/17>`_).

* No privilege elevation mechanism support:

  * No SUID binaries, SUID binaries disabled, all partitions mounted with the
    ``nosuid`` mount option.
  * Capability bounding sets
  * No new privileges flag (``no_new_privs``) set for the PID 1 process.

  .. admonition:: Status
     :class: notice

     In progress. Status as of version **5.0 beta**:

     * All SetUID bits are stripped from the system.
     * All partitions are mounted with the ``nosuid`` mount option.

System and user authentication separation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Storage space for system and user authentication secrets are separated.

.. admonition:: Status
   :class: warning

   Not started.

Non-persistency of potential system or user session compromise
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* Privileged user (i.e., ``root``) level compromises are mitigated against
  persistency methods which make use of the filesystem. Such compromises would
  have their lifecycles limited to system boot lifetime (uptime).

  .. admonition:: Status
     :class: notice

     In progress.

* Unprivileged user level (i.e., the current user) compromises are mitigated
  against persistency methods which make use of the filesystem. Such
  compromises would have their lifecycles limited to the compromised user
  session lifetime.

  .. admonition:: Status
     :class: warning

     Not started.

Journaling
^^^^^^^^^^

* "Append-mostly" log storage and automatic rotation using
  ``systemd-journald``.

  .. admonition:: Status
     :class: tip

     Completed in version **5.0 alpha**.

* Append-only log storage and automatic log rotation.

  .. admonition:: Status
     :class: warning

     Not started.

* Log forwarding to remote storage.

  .. admonition:: Status
     :class: warning

     Not started.

Robust update system
^^^^^^^^^^^^^^^^^^^^

* Atomic, in-background and non-intrusive upgrade mechanism using A/B
  partitions (similar to Android or ChromeOS).

  .. admonition:: Status
     :class: tip

     Completed in version **5.0 beta** (`clipos/bugs#9
     <https://github.com/clipos/bugs/issues/9>`_).

* Fallback version available in case of unpredicted failure or bug.

  .. admonition:: Status
     :class: tip

     Completed in version **5.0 beta** (`clipos/bugs#9
     <https://github.com/clipos/bugs/issues/9>`_).

* Update transport protection:

  Transport using TLS 1.2 or 1.3 only, with pinned root CA certificate.

  .. admonition:: Status
     :class: tip

     Completed in version **5.0 beta** (`clipos/bugs#9
     <https://github.com/clipos/bugs/issues/9>`_).

* Update integrity protection and verification:

  Signed updates using `minisign <https://jedisct1.github.io/minisign/>`_.

  .. admonition:: Status
     :class: tip

     Completed in version **5.0 beta** (`clipos/bugs#9
     <https://github.com/clipos/bugs/issues/9>`_).

* Supports updating both the system and other environments.

  .. admonition:: Status
     :class: warning

     Not started.

* Rollback protection.

  .. admonition:: Status
     :class: warning

     Not started.

* Server-side channel and version selection for delivery to clients.

  .. admonition:: Status
     :class: warning

     Not started.

Remote attestation
^^^^^^^^^^^^^^^^^^

Remote version, configuration and system state attestation using the TPM.

.. admonition:: Status
   :class: warning

   Not started.

Linux kernel confidentiality
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The initial EFI boot binaries must reside in clear text on the disk to allow
automatic system startup. If kernel image confidentiality protection is
required, an additional kernel image and initramfs will be stored inside the
encrypted system partition. The initial initramfs will thus kexec the new
kernel and initramfs during boot time.

.. admonition:: Status
   :class: warning

   Not started.

Linux kernel provided security
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. admonition:: Status
   :class: notice

   In progress. Please refer to the :ref:`kernel` page for details.

Linux kernel hardening
^^^^^^^^^^^^^^^^^^^^^^

* The kernel is carefully configured and only strictly required options are
  enabled. Each rationale behind those options is documented.

  Hardware support uses kernel modules which are loaded following tailored
  profiles (per hardware platform). Kernel modules loading is disabled at a
  very early stage of the system startup once the system is considered booted
  and shall not require any additional kernel module later on.

  The kernel protects itself from attacks originating from userspace (``root``
  user included).

  .. admonition:: Status
     :class: notice

     In progress. Please refer to the :ref:`kernel` page for details.


Full sub-environment isolation using hardware-assisted virtualization
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* Support for KVM based virtualization and paravirtualized drivers only
  (i.e., ``virtio`` drivers).

  .. admonition:: Status
     :class: warning

     Not started.

* Minimal QEMU configuration.

  .. admonition:: Status
     :class: warning

     Not started.

* QEMU process instances are confined.

  .. admonition:: Status
     :class: warning

     Not started.

* Alternative system virtualizer as a replacement for QEMU (nemu, crosvm,
  etc.).

  .. admonition:: Status
     :class: warning

     Not started.

Safe operation of untrusted filesystem
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* FUSE-based userspace mount of untrusted file systems.

  .. admonition:: Status
     :class: warning

     Not started.

* Virtual machine-based in-kernel mounting and sharing using NFS, CIFS, 9P,
  VirtFS, etc.

  .. admonition:: Status
     :class: warning

     Not started.

Network setup, isolation and access control
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* Automatic and manual network configuration.

  .. admonition:: Status
     :class: warning

     Not started.

* Automatic IPsec tunnel setup once network access is configured.

  .. admonition:: Status
     :class: warning

     Not started.

* Access control, isolation and IPSec usage enforcement for host and
  environments.

  .. admonition:: Status
     :class: warning

     Not started.

Multi-level environment
^^^^^^^^^^^^^^^^^^^^^^^

* Host and sub-environment service and application isolation using Linux
  namespaces, cgroups, seccomp-bpf filters, etc.

  .. admonition:: Status
     :class: notice

     In progress.

* Multi-level enforcement using an LSM inspired from Vserver.

  .. admonition:: Status
     :class: warning

     Not started.

* Configurable sub environments restrictions and network access.

  .. admonition:: Status
     :class: warning

     Not started.

* Safe and controlled communication to the host:

  * Unix sockets or encrypted TCP sockets (SSH)
  * vsocks (virtio)

  .. admonition:: Status
     :class: warning

     Not started.

* Host controlled inter-level communication:

  * File passing diode
  * Encrypting / decryption diode
  * Smartcard proxy and command filtering (see *Caml Crush* project)

  .. admonition:: Status
     :class: warning

     Not started.

* Intra-level application isolation using Flatpak.

  .. admonition:: Status
     :class: warning

     Not started.

Remote administration and fleet management
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. admonition:: Status
   :class: warning

   Not started.

Automatic provisioning and installation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. admonition:: Status
   :class: warning

   Not started.

Safe recovery mode for backup and administration performed recovery
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. admonition:: Status
   :class: warning

   Not started.

Mandatory Access Control
^^^^^^^^^^^^^^^^^^^^^^^^

.. admonition:: Status
   :class: warning

   Not started.

Certification and Common Criteria Evaluation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. admonition:: Status
   :class: warning

   Not started.

User-related properties
~~~~~~~~~~~~~~~~~~~~~~~

User data confidentiality and integrity
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* User data partition protected by DM-Crypt + DM-Integrity with a user provided
  secret.

  .. admonition:: Status
     :class: warning

     Not started.

* User storage partition unlocking with password.

  .. admonition:: Status
     :class: warning

     Not started.

* User storage partition unlocking with smartcard.

  .. admonition:: Status
     :class: warning

     Not started.

* User storage partition unlocking with a security token (e.g., U2F/FIDO).

  .. admonition:: Status
     :class: warning

     Not started.

Device access control
^^^^^^^^^^^^^^^^^^^^^

* Device whitelisting.

  .. admonition:: Status
     :class: warning

     Not started.

* Multi-level aware device assignation.

  .. admonition:: Status
     :class: warning

     Not started.

* USB device management (e.g., USBGuard).

  .. admonition:: Status
     :class: warning

     Not started.

Graphical interface properties
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Trusted graphical interface
^^^^^^^^^^^^^^^^^^^^^^^^^^^

* Root compositor.

  .. admonition:: Status
     :class: warning

     Not started.

* Wayland protocol based environment.

  .. admonition:: Status
     :class: warning

     Not started.

* Trusted graphical components and display (trusted panel).

  .. admonition:: Status
     :class: warning

     Not started.

* Protected lock-screen.

  .. admonition:: Status
     :class: warning

     Not started.

* Protected input.

  .. admonition:: Status
     :class: warning

     Not started.

Restricted users
^^^^^^^^^^^^^^^^

.. admonition:: Status
   :class: warning

   Not started.

Application access control
^^^^^^^^^^^^^^^^^^^^^^^^^^

.. admonition:: Status
   :class: warning

   Not started.

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
