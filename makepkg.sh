#!/bin/bash
qemu="/opt/qemu-2.2.0/arm-softmmu/qemu-system-arm"
ssh="ssh  -o StrictHostKeyChecking=no root@127.0.0.1 -p2222"
pacman="pacman --noconfirm --force --needed"
export QEMU_AUDIO_DRV=none
$qemu -daemonize -M vexpress-a9 -kernel zImage \
	-drive file=root.img,if=sd,cache=none -append "root=/dev/mmcblk0p2 rw" \
	-m 512 -net nic -net user,hostfwd=tcp::2222-:22 -snapshot
sleep 20

echo "### Install requirements ###"
$ssh "pacman-db-upgrade"
$ssh "$pacman -Syu"
$ssh "$pacman -S git vim ntp nginx aiccu python2 python2-distribute avahi wget"
$ssh "$pacman -S python2-virtualenv alsa-plugins alsa-utils gcc make redis sudo fake-hwclock"
$ssh "$pacman -S python2-numpy ngrep tcpdump lldpd"
$ssh "$pacman -S spandsp gsm celt"
$ssh "$pacman -S hiredis libmicrohttpd"

wget https://github.com/Studio-Link/PKGBUILDs/raw/master/jack2/jack2-14.8.0-1-armv7h.pkg.tar.xz
$pacman -U jack2-14.8.0-1-armv7h.pkg.tar.xz

echo "### Install build requirements ###"
$ssh "$pacman -S base-devel"

$ssh "git clone https://github.com/Studio-Link/PKGBUILDs.git"

echo "### Build ###"
makepkg="makepkg --asroot --force --install --noconfirm"
$ssh "cd PKGBUILDs/libre; $makepkg"
$ssh "cd PKGBUILDs/librem; $makepkg"
$ssh "cd PKGBUILDs/baresip; $makepkg"
