.. Copyright © 2018 ANSSI.
   CLIP OS is a trademark of the French Republic.
   Content licensed under the Open License version 2.0 as published by Etalab
   (French task force for Open Data).

Boot chain and integrity guarantees
===================================

On-disk layout
--------------

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
   "mainvg", "core_state", "None (Planned: DM-Crypt + DM-Integrity block
   device)", "ext4 filesystem"

Boot chain order
----------------

.. sidebar:: Boot chain order

   .. _clipos-boot-order:
   .. figure:: imgs/clipos-boot-order.svg
      :align: center

      Boot chain order

As shown in :numref:`clipos-boot-order`, the boot steps (following hardware
initialization) are as follows:

#. The UEFI Firmware will execute the initial bootloader from the EFI system
   partition.

#. Following the `Boot Loader Specification <The Boot Loader Specification>`_,
   the bootloader (gummiboot/systemd-boot) will execute the EFI binary in the
   ``EFI/Linux`` folder with the highest version number.

#. The executed EFI binary is a bundle created by `dracut
   <http://man7.org/linux/man-pages/man8/dracut.8.html>`_ which wraps a Linux
   kernel, its command line and an initramfs. The initramfs will open the
   ``core-<version>`` DM-Verity block device and mount the SquashFS filesystem
   in ``/sysroot``. Then it will mount the ``core_state`` ext4 partition in
   ``/sysroot/mnt/state``. Finally, it will perform a pivot_root to switch to
   the final root.


Boot chain and rootfs integrity
-------------------------------

The integrity of the boot chain and root filesystem is guaranteed by the
following mechanisms.

Secure Boot
~~~~~~~~~~~

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
~~~~~~~~~

Once the kernel is booted with the initial initramfs, it will look for the
``core-<version>`` LVM Logical Volume which includes a DM-Verity block device.
The ``root hash`` used to verify the integrity of this partition is included in
the kernel command line (thus protected in integrity by Secure Boot). This
assures the integrity of the content of the DM-Verity block device, which
includes the read-only uncompressed SquashFS root filesystem. Support for
forward error correction (FEC) is also enabled thus increasing resistance to
disk read errors or failures.

Setup for testing
-----------------

Under QEMU with OVMF
~~~~~~~~~~~~~~~~~~~~

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

With real hardware
~~~~~~~~~~~~~~~~~~

This is not supported at the moment. The main difference is that Secure Boot
keys will need to be enrolled through the manufacturer's UEFI firmware.
However, we expect the EFI binary mentioned above to make this step as
automated as possible.

.. vim: set tw=79 ts=2 sts=2 sw=2 et:
