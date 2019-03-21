.. Copyright © 2018 ANSSI.
   CLIP OS is a trademark of the French Republic.
   Content licensed under the Open License version 2.0 as published by Etalab
   (French task force for Open Data).

===================================
Boot chain and integrity guarantees
===================================

On-disk layout
==============

.. sidebar:: Disk partition layout

   .. _clipos-disk-layout:
   .. figure:: imgs/clipos-disk-layout.svg
      :align: center

      Disk partition layout

The main disk GPT partition layout is as follows (:numref:`clipos-disk-layout`):

#. EFI system partition (ESP) which includes:

   * The EFI bootloader and its configuration;
   * An EFI binary for each version currently installed (usually two, but only
     one at installation time). Each EFI binary bundles a Linux kernel, its
     command line and an initramfs.

#. LVM partition which holds all LVM Volume Groups and Logical Volumes for the
   system. The currently available ones are:

.. csv-table::
   :header: "Volume Group", "Logical Volume", "Layer", "Filesystem"
   :widths: 1, 1, 5, 5

   "mainvg", "core_<version>", "DM-Verity block device and metadata appended at
   the end", "Uncompressed squashfs filesystem"
   "mainvg", "core_state", "DM-Crypt + DM-Integrity block device", "ext4
   filesystem"
   "mainvg", "swap", "DM-Crypt with a random key generated at boot time", "N/A"

Boot chain order
================

.. sidebar:: Boot chain order

   .. _clipos-boot-order:
   .. figure:: imgs/clipos-boot-order.svg
      :align: center

      Boot chain order

As shown in :numref:`clipos-boot-order`, the boot steps (following hardware
initialization) are as follows:

#. The UEFI Firmware executes the initial bootloader from the EFI system
   partition.

#. Following the `Boot Loader Specification
   <https://systemd.io/BOOT_LOADER_SPECIFICATION.html>`_, the bootloader
   (gummiboot/systemd-boot) executes the EFI binary in the ``EFI/Linux`` folder
   with the highest version number. The executed EFI binary is a bundle created
   by `dracut <http://man7.org/linux/man-pages/man8/dracut.8.html>`_ which
   wraps a Linux kernel, its command line and an initramfs.

#. The initramfs opens the ``core-<version>`` DM-Verity block device and mounts
   the SquashFS filesystem in ``/sysroot``. Then, using the TPM, it unseals the
   key required to open the DM-Crypt/DM-Integrity ``core_state`` partition and
   mounts the resulting ext4 partition in ``/sysroot/mnt/state``. Finally, it
   performs a pivot_root to switch to the final root.


Boot chain and rootfs integrity
===============================

The integrity of the boot chain and root filesystem is guaranteed by the
following mechanisms.

Secure Boot
-----------

All EFI binaries installed in the EFI System Partition (ESP) are
signed in order to protect their integrity *via* Secure Boot. Their
confidentiality however is not assured. Currently, two EFI binaries are
necessary:

* The **systemd-boot EFI bootloader**. Its only purpose is to execute the
  latest CLIP OS EFI binary. This bootloader is minimal and only acts as a
  switch between the available CLIP OS versions. This enables recovery in case
  of update failure or temporary rollback due to bugs in a new version.

* The **main CLIP OS EFI binary**. It contains the initial kernel image, the
  initramfs and the kernel command line. Signing this binary guarantees the
  integrity of its three components. Note that the kernel command line also
  includes the DM-Verity root hash for the CLIP OS Core partition. This binary
  is chosen by the bootloader and the Secure Boot signature verification is
  performed by the UEFI Firmware.

No default keys are supported (e.g., Microsoft keys) thus you will need to
generate you own Secure Boot signing keys and use them during the build
process. Those keys must then be enrolled in hardware.

DM-Verity
---------

Once the kernel is booted with the initial initramfs, it will look for the
``core-<version>`` LVM Logical Volume which includes a DM-Verity block device.
The ``root hash`` used to verify the integrity of this partition is included in
the kernel command line (thus protected in integrity by Secure Boot). This
assures the integrity of the content of the DM-Verity block device, which
includes the read-only uncompressed SquashFS root filesystem. Support for
forward error correction (FEC) is also enabled thus increasing resistance to
disk read errors or failures.

Trusted Boot
------------

Objective
~~~~~~~~~

We want to achieve full-disk encryption in a way that is both secure and
unnoticeable to the end user. The TPM enables us to do that by sealing the
encryption key and providing it at boot time if and only if the machine is in a
known-good state (via PCRs extension). In other words, we want to be able to
decrypt the disk only once we *prove* we have booted trusted code.

However, we would like to avoid re-sealing the encryption key every single
time we upgrade the kernel, the initramfs or the command line.

Chosen Solution
~~~~~~~~~~~~~~~

We already have Secure Boot, ensuring the UEFI firmware boots our signed EFI
binary containing the kernel, the initramfs and the command line. In other
words, we already *assert* the boot of trusted code.

A `specification <https://docs.microsoft.com/en-us/previous-versions/windows/hardware/hck/jj923068(v=vs.85)#appendix_a__static_root_of_trust_measurements>`_,
pointed out `here <https://mjg59.dreamwidth.org/48897.html>`_, exists that
combines Secure and Trusted Boot, using PCR 7, by:

* recording whether Secure Boot is turned on;
* recording the key database;
* recording which keys were used.

By sealing the disk-encryption key according to the PCR 7 value, we ensure that
the disk is decrypted if and only if our Secure Boot policy has not been
tampered with, which in turn means that we booted a trusted EFI binary, i.e.
trusted kernel, initramfs and command line.

Naturally, we can in addition use most if not all PCRs 0 to 6 to measure
firmware integrity. In the future, we may also use an additional PCR to
measure the LUKS header(s), similarly to what
`TrustedGRUB2 <https://github.com/Rohde-Schwarz-Cybersecurity/TrustedGRUB2>`_
does with PCR 12.

Implementation Choices
~~~~~~~~~~~~~~~~~~~~~~

TPM specification
*****************

We rely on TPM 2.0, for various reasons including:

* TPM 1.2 only supports deprecated cryptographic algorithms and TrouSerS is
  hard to deal with and not satisfying (partly due to tcsd);
* TPM 2.0 is already replacing TPM 1.2 in new machines;
* TPM 2.0 offers several new interesting functionalities, such as multiple
  hierarchies.

One issue with TPM 2.0 is that utilities and libraries to deal with it are
still under heavy development. We chose to use the `tpm2-tools
<https://github.com/tpm2-software/tpm2-tools>`_, which rely on the `tpm2-tss
<https://github.com/tpm2-software/tpm2-tss>`_ implementation of the TCG's TPM2
Software Stack (TSS2).

Initramfs and LUKS
******************

* We use a Bash script located in our initramfs.
* TPM-sealed LUKS keyfiles are located in the EFI System Partition.
* The kernel's Resource Manager (RM) is used to ease objects management.
  Basically, the RM presents each new call to a ``tpm2_*`` tool with an empty
  TPM (i.e. it cleans transient objects when the file handle to ``/dev/tpmrm0``
  is closed).
* We use the Owner Hierarchy (OH) and leave the Endorsement Hierarchy (EH) for
  remote attestation.
* One could make the primary object persistent (with ``tpm2_evictcontrol``) to
  avoid re-derivating it from the seed each time and save some time at the
  expense of additional complexity.
* We do not directly make the loaded keyfile object persistent as we would not
  have enough space in the TPM for all keyfiles we are going to want to use.

Planned Improvements
********************

* We would like to use different PCR lists for a given machine's first boots
  following/during its provisioning, as we may for instance change its BIOS
  configuration.
* We would like to use keyctl in order to directly store the decrypted LUKS key
  in a kernel keyslot so that cryptsetup can use it without it being passed
  through userspace. Note that, currently, keyfiles are in memory and may be
  swapped to disk, but that is tolerable as we use an encrypted swap device.
  Another solution could be to use ramfs instead of tmpfs.

Setup for testing
=================

Under QEMU with OVMF
--------------------

Secure Boot
~~~~~~~~~~~

As a short term solution, we use hard-coded dummy keys to sign the EFI binaries
with **sbsigntools** and ship an OVMF VARS template file in which these keys
have been manually enrolled.

The optimal way of setting up Secure Boot for a virtual machine will be to
develop and use an EFI binary to automatically enroll PK, KEK and db keys,
similarly to `what Fedora is performing
<https://github.com/puiterwijk/qemu-ovmf-secureboot>`_.  Such keys would be
generated at build time for a given deployment using the relevant PKI.

The standard CLIP OS build process includes build steps to enable Secure Boot
testing under QEMU with OVMF.

Trusted Boot
~~~~~~~~~~~~

QEMU (and libvirt) support two TPM backends:

* TPM passthrough device: requires the end user to have a hardware TPM on its
  host machine, which in addition cannot be used simultaneously by anything
  else. There are also some problems due to the way the TPM is initialized by
  the host, and thus some commands used by the guest cannot work as expected,
  and so on.
* TPM emulator: provides TPM functionality for each VM using a TPM emulator
  installed on the host. `swtpm <https://github.com/stefanberger/swtpm>`_ is
  currently the only supported emulator.

The second option is more adapted to our needs but requires people to install
swtpm, which requires `libtpms <https://github.com/stefanberger/libtpms>`_.

The EFI firmware (OVMF) needs to be built with TPM support. We provide and use
our own derived ``sys-firmware/edk2-ovmf`` to enable Secure Boot and TPM
support.

With real hardware
------------------

This is not supported at the moment. The main difference is that Secure Boot
keys will need to be enrolled through the manufacturer's UEFI firmware.
However, we expect the EFI binary mentioned above to make this step as
automated as possible.

.. vim: set tw=79 ts=2 sts=2 sw=2 et:
