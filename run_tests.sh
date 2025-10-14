#!/usr/bin/env bash
#shellcheck disable=SC2115

cd /tmp || exit 1

cp /tmp/installkernel-gentoo-9999/installkernel-9999.ebuild /var/db/repos/gentoo/sys-kernel/installkernel/installkernel-9999.ebuild || exit 1
ls -la /tmp/installkernel-gentoo-9999/ || exit 1
ebuild /var/db/repos/gentoo/sys-kernel/installkernel/installkernel-9999.ebuild manifest || exit 1

INST_KERN="$(ls /boot/kernel*-gentoo-dist* || exit 1)"
INST_KV_FULL="${INST_KERN#/boot/kernel-}"
INST_KV="${INST_KV_FULL%-gentoo-dist}"

# Create a fake ESP
dd if=/dev/zero of=/fake-efi bs=1024 count=204800 || exit 1
FAKE_EFI="$(losetup -f)"
losetup "${FAKE_EFI}" /fake-efi || exit 1
mkfs.vfat -F 32 "${FAKE_EFI}" || exit 1
mkdir -p /efi || exit 1
mount -t vfat "${FAKE_EFI}" /efi || exit 1

# Generate with:
#
# import itertools
#
# for i in itertools.product(['-',''],repeat=7):
#     print(f"TEST_CASES[\"{i[0]}generic-uki {i[1]}dracut {i[2]}systemd {i[3]}systemd-boot {i[4]}uki {i[5]}ukify {i[6]}grub\"]=\\")
#
# And manually filter nonsense configurations:
# - generic-uki at the same time as dracut and/or ukify
# - systemd-boot without systemd
# - uki without dracut or ukify
declare -A TEST_CASES

TEST_CASES["-generic-uki -dracut -systemd -systemd-boot -uki -ukify -grub -refind"]=\
"/boot
/boot/System.map-${INST_KV}-gentoo-dist
/boot/config-${INST_KV}-gentoo-dist
/boot/vmlinuz-${INST_KV}-gentoo-dist
/efi
/efi/EFI

3 directories, 3 files"
TEST_CASES["-generic-uki -dracut -systemd -systemd-boot -uki -ukify grub -refind"]=\
"/boot
/boot/System.map-${INST_KV}-gentoo-dist
/boot/config-${INST_KV}-gentoo-dist
/boot/grub
/boot/vmlinuz-${INST_KV}-gentoo-dist
/efi
/efi/EFI

4 directories, 3 files"
TEST_CASES["-generic-uki -dracut -systemd -systemd-boot uki ukify -grub -refind"]=\
"/boot
/efi
/efi/EFI
/efi/EFI/Linux
/efi/EFI/Linux/gentoo-${INST_KV}-gentoo-dist.efi

3 directories, 1 file"
TEST_CASES["-generic-uki -dracut -systemd -systemd-boot uki ukify grub -refind"]=\
"/boot
/boot/grub
/efi
/efi/EFI
/efi/EFI/Linux
/efi/EFI/Linux/gentoo-${INST_KV}-gentoo-dist.efi

5 directories, 1 file"
TEST_CASES["-generic-uki -dracut systemd -systemd-boot -uki -ukify -grub -refind"]=\
"/boot
/boot/kernel-${INST_KV}-gentoo-dist
/efi
/efi/EFI

3 directories, 1 file"
TEST_CASES["-generic-uki -dracut systemd -systemd-boot -uki -ukify grub -refind"]=\
"/boot
/boot/grub
/boot/kernel-${INST_KV}-gentoo-dist
/efi
/efi/EFI

4 directories, 1 file"
TEST_CASES["-generic-uki -dracut systemd -systemd-boot uki ukify -grub -refind"]=\
"/boot
/efi
/efi/EFI
/efi/EFI/Linux
/efi/EFI/Linux/gentoo-${INST_KV}-gentoo-dist.efi

3 directories, 1 file"
TEST_CASES["-generic-uki -dracut systemd -systemd-boot uki ukify grub -refind"]=\
"/boot
/boot/grub
/efi
/efi/EFI
/efi/EFI/Linux
/efi/EFI/Linux/gentoo-${INST_KV}-gentoo-dist.efi

5 directories, 1 file"
TEST_CASES["-generic-uki -dracut systemd systemd-boot -uki -ukify -grub -refind"]=\
"/boot
/efi
/efi/EFI
/efi/gentoo
/efi/gentoo/${INST_KV}-gentoo-dist
/efi/gentoo/${INST_KV}-gentoo-dist/linux
/efi/loader
/efi/loader/entries
/efi/loader/entries/gentoo-${INST_KV}-gentoo-dist.conf

6 directories, 2 files"
TEST_CASES["-generic-uki -dracut systemd systemd-boot uki ukify -grub -refind"]=\
"/boot
/efi
/efi/EFI
/efi/EFI/Linux
/efi/EFI/Linux/gentoo-${INST_KV}-gentoo-dist.efi

3 directories, 1 file"
TEST_CASES["-generic-uki dracut -systemd -systemd-boot -uki -ukify -grub -refind"]=\
"/boot
/boot/System.map-${INST_KV}-gentoo-dist
/boot/config-${INST_KV}-gentoo-dist
/boot/initramfs-${INST_KV}-gentoo-dist.img
/boot/vmlinuz-${INST_KV}-gentoo-dist
/efi
/efi/EFI

3 directories, 4 files"
TEST_CASES["-generic-uki dracut -systemd -systemd-boot -uki -ukify grub -refind"]=\
"/boot
/boot/System.map-${INST_KV}-gentoo-dist
/boot/config-${INST_KV}-gentoo-dist
/boot/grub
/boot/initramfs-${INST_KV}-gentoo-dist.img
/boot/vmlinuz-${INST_KV}-gentoo-dist
/efi
/efi/EFI

4 directories, 4 files"
TEST_CASES["-generic-uki dracut -systemd -systemd-boot uki -ukify -grub -refind"]=\
"/boot
/efi
/efi/EFI
/efi/EFI/Linux
/efi/EFI/Linux/gentoo-${INST_KV}-gentoo-dist.efi

3 directories, 1 file"
TEST_CASES["-generic-uki dracut -systemd -systemd-boot uki -ukify grub -refind"]=\
"/boot
/boot/grub
/efi
/efi/EFI
/efi/EFI/Linux
/efi/EFI/Linux/gentoo-${INST_KV}-gentoo-dist.efi

5 directories, 1 file"
TEST_CASES["-generic-uki dracut -systemd -systemd-boot uki ukify -grub -refind"]=\
"/boot
/efi
/efi/EFI
/efi/EFI/Linux
/efi/EFI/Linux/gentoo-${INST_KV}-gentoo-dist.efi

3 directories, 1 file"
TEST_CASES["-generic-uki dracut -systemd -systemd-boot uki ukify grub -refind"]=\
"/boot
/boot/grub
/efi
/efi/EFI
/efi/EFI/Linux
/efi/EFI/Linux/gentoo-${INST_KV}-gentoo-dist.efi

5 directories, 1 file"
TEST_CASES["-generic-uki dracut systemd -systemd-boot -uki -ukify -grub -refind"]=\
"/boot
/boot/initramfs-${INST_KV}-gentoo-dist.img
/boot/kernel-${INST_KV}-gentoo-dist
/efi
/efi/EFI

3 directories, 2 files"
TEST_CASES["-generic-uki dracut systemd -systemd-boot -uki -ukify grub -refind"]=\
"/boot
/boot/grub
/boot/initramfs-${INST_KV}-gentoo-dist.img
/boot/kernel-${INST_KV}-gentoo-dist
/efi
/efi/EFI

4 directories, 2 files"
TEST_CASES["-generic-uki dracut systemd -systemd-boot uki -ukify -grub -refind"]=\
"/boot
/efi
/efi/EFI
/efi/EFI/Linux
/efi/EFI/Linux/gentoo-${INST_KV}-gentoo-dist.efi

3 directories, 1 file"
TEST_CASES["-generic-uki dracut systemd -systemd-boot uki -ukify grub -refind"]=\
"/boot
/boot/grub
/efi
/efi/EFI
/efi/EFI/Linux
/efi/EFI/Linux/gentoo-${INST_KV}-gentoo-dist.efi

5 directories, 1 file"
TEST_CASES["-generic-uki dracut systemd -systemd-boot uki ukify -grub -refind"]=\
"/boot
/efi
/efi/EFI
/efi/EFI/Linux
/efi/EFI/Linux/gentoo-${INST_KV}-gentoo-dist.efi

3 directories, 1 file"
TEST_CASES["-generic-uki dracut systemd -systemd-boot uki ukify grub -refind"]=\
"/boot
/boot/grub
/efi
/efi/EFI
/efi/EFI/Linux
/efi/EFI/Linux/gentoo-${INST_KV}-gentoo-dist.efi

5 directories, 1 file"
TEST_CASES["-generic-uki dracut systemd systemd-boot -uki -ukify -grub -refind"]=\
"/boot
/efi
/efi/EFI
/efi/gentoo
/efi/gentoo/${INST_KV}-gentoo-dist
/efi/gentoo/${INST_KV}-gentoo-dist/initrd
/efi/gentoo/${INST_KV}-gentoo-dist/linux
/efi/loader
/efi/loader/entries
/efi/loader/entries/gentoo-${INST_KV}-gentoo-dist.conf

6 directories, 3 files"
TEST_CASES["-generic-uki dracut systemd systemd-boot uki -ukify -grub -refind"]=\
"/boot
/efi
/efi/EFI
/efi/EFI/Linux
/efi/EFI/Linux/gentoo-${INST_KV}-gentoo-dist.efi

3 directories, 1 file"
TEST_CASES["-generic-uki dracut systemd systemd-boot uki ukify -grub -refind"]=\
"/boot
/efi
/efi/EFI
/efi/EFI/Linux
/efi/EFI/Linux/gentoo-${INST_KV}-gentoo-dist.efi

3 directories, 1 file"
TEST_CASES["generic-uki -dracut -systemd -systemd-boot -uki -ukify -grub -refind"]=\
"/boot
/boot/System.map-${INST_KV}-gentoo-dist
/boot/config-${INST_KV}-gentoo-dist
/boot/initramfs-${INST_KV}-gentoo-dist.img
/boot/vmlinuz-${INST_KV}-gentoo-dist
/efi
/efi/EFI

3 directories, 4 files"
TEST_CASES["generic-uki -dracut -systemd -systemd-boot -uki -ukify grub -refind"]=\
"/boot
/boot/System.map-${INST_KV}-gentoo-dist
/boot/config-${INST_KV}-gentoo-dist
/boot/grub
/boot/initramfs-${INST_KV}-gentoo-dist.img
/boot/vmlinuz-${INST_KV}-gentoo-dist
/efi
/efi/EFI

4 directories, 4 files"
TEST_CASES["generic-uki -dracut -systemd -systemd-boot uki -ukify -grub -refind"]=\
"/boot
/efi
/efi/EFI
/efi/EFI/Linux
/efi/EFI/Linux/gentoo-${INST_KV}-gentoo-dist.efi

3 directories, 1 file"
TEST_CASES["generic-uki -dracut -systemd -systemd-boot uki -ukify grub -refind"]=\
"/boot
/boot/grub
/efi
/efi/EFI
/efi/EFI/Linux
/efi/EFI/Linux/gentoo-${INST_KV}-gentoo-dist.efi

5 directories, 1 file"
TEST_CASES["generic-uki -dracut systemd -systemd-boot -uki -ukify -grub -refind"]=\
"/boot
/boot/initramfs-${INST_KV}-gentoo-dist.img
/boot/kernel-${INST_KV}-gentoo-dist
/efi
/efi/EFI

3 directories, 2 files"
TEST_CASES["generic-uki -dracut systemd -systemd-boot -uki -ukify grub -refind"]=\
"/boot
/boot/grub
/boot/initramfs-${INST_KV}-gentoo-dist.img
/boot/kernel-${INST_KV}-gentoo-dist
/efi
/efi/EFI

4 directories, 2 files"
TEST_CASES["generic-uki -dracut systemd -systemd-boot uki -ukify -grub -refind"]=\
"/boot
/efi
/efi/EFI
/efi/EFI/Linux
/efi/EFI/Linux/gentoo-${INST_KV}-gentoo-dist.efi

3 directories, 1 file"
TEST_CASES["generic-uki -dracut systemd -systemd-boot uki -ukify grub -refind"]=\
"/boot
/boot/grub
/efi
/efi/EFI
/efi/EFI/Linux
/efi/EFI/Linux/gentoo-${INST_KV}-gentoo-dist.efi

5 directories, 1 file"
TEST_CASES["generic-uki -dracut systemd systemd-boot -uki -ukify -grub -refind"]=\
"/boot
/efi
/efi/EFI
/efi/gentoo
/efi/gentoo/${INST_KV}-gentoo-dist
/efi/gentoo/${INST_KV}-gentoo-dist/initrd
/efi/gentoo/${INST_KV}-gentoo-dist/linux
/efi/loader
/efi/loader/entries
/efi/loader/entries/gentoo-${INST_KV}-gentoo-dist.conf

6 directories, 3 files"
TEST_CASES["generic-uki -dracut systemd systemd-boot uki -ukify -grub -refind"]=\
"/boot
/efi
/efi/EFI
/efi/EFI/Linux
/efi/EFI/Linux/gentoo-${INST_KV}-gentoo-dist.efi

3 directories, 1 file"
TEST_CASES["-generic-uki -dracut -systemd -systemd-boot -uki -ukify -grub refind"]=\
"/boot
/boot/System.map-${INST_KV}-gentoo-dist
/boot/config-${INST_KV}-gentoo-dist
/boot/vmlinuz-${INST_KV}-gentoo-dist
/boot/vmlinuz-${INST_KV}-gentoo-dist.png
/efi
/efi/EFI

3 directories, 4 files"
TEST_CASES["-generic-uki -dracut -systemd -systemd-boot uki ukify -grub refind"]=\
"/boot
/efi
/efi/EFI
/efi/EFI/Linux
/efi/EFI/Linux/gentoo-${INST_KV}-gentoo-dist.efi
/efi/EFI/Linux/gentoo-${INST_KV}-gentoo-dist.png

3 directories, 2 files"
TEST_CASES["-generic-uki -dracut systemd -systemd-boot -uki -ukify -grub refind"]=\
"/boot
/boot/kernel-${INST_KV}-gentoo-dist
/boot/kernel-${INST_KV}-gentoo-dist.png
/efi
/efi/EFI

3 directories, 2 files"
TEST_CASES["generic-uki -dracut systemd -systemd-boot -uki -ukify -grub refind"]=\
"/boot
/boot/initramfs-${INST_KV}-gentoo-dist.img
/boot/kernel-${INST_KV}-gentoo-dist
/boot/kernel-${INST_KV}-gentoo-dist.png
/efi
/efi/EFI

3 directories, 3 files"
TEST_CASES["-generic-uki -dracut systemd -systemd-boot uki ukify -grub refind"]=\
"/boot
/efi
/efi/EFI
/efi/EFI/Linux
/efi/EFI/Linux/gentoo-${INST_KV}-gentoo-dist.efi
/efi/EFI/Linux/gentoo-${INST_KV}-gentoo-dist.png

3 directories, 2 files"

FAILURES=()

for case in "${!TEST_CASES[@]}"; do
	rm -rf /boot/* /efi/* || { echo "Error at case USE=\"${case}\"" && exit 1; }
	mkdir -p /efi/EFI || { echo "Error at case USE=\"${case}\"" && exit 1; }
	echo "Testing case USE=\"${case}\" ..."

	emerge --rage-clean --quiet --quiet-unmerge-warn sys-kernel/gentoo-kernel-bin || { echo "Error at case USE=\"${case}\"" && exit 1; }
	USE="${case}" emerge --quiet '=sys-kernel/installkernel-9999' || { echo "Error at case USE=\"${case}\"" && exit 1; }
	INSTALLKERNEL_VERBOSE=1 USE="${case}" emerge --quiet sys-kernel/gentoo-kernel-bin || { echo "Error at case USE=\"${case}\"" ; cat "/var/tmp/portage/sys-kernel/gentoo-kernel-bin-${INST_KV}/temp/build.log" ; exit 1; }
	tree="$(tree -ifnav /boot /efi)"
	if [[ "${TEST_CASES[${case}]}" == "${tree}" ]]; then
		echo "Case USE=\"${case}\" matches"
	else
		echo "Case USE=\"${case}\" does not match!"

FAILURES+=("
Case USE=\"${case}\" failed:
Expected:
${TEST_CASES[${case}]}

Actual:
${tree}
")
	fi
done

echo ""

# Cleanup fake ESP
rm -rf /boot/* /efi/* || exit 1
umount /efi || exit 1
losetup -d "${FAKE_EFI}" || exit 1

if [[ ${#FAILURES[@]} -eq 0 ]]; then
	echo "All tests succeeded"
	exit 0
else
	echo "The following ${#FAILURES[@]} tests failed"
	(IFS=$'\n'; echo "${FAILURES[*]}")
	exit 1
fi
