#!/bin/bash -ex
qemu="/opt/qemu-2.2.0/arm-softmmu/qemu-system-arm"
ssh="ssh  -o StrictHostKeyChecking=no root@127.0.0.1 -p2222"
scp="scp -P2222 -r root@127.0.0.1:"
pacman="pacman --noconfirm --force --needed"
version="15.1.0-beta"
export QEMU_AUDIO_DRV=none
$qemu -daemonize -M vexpress-a9 -smp 2 -kernel zImage \
	-drive file=root.img,if=sd,cache=none -append "root=/dev/mmcblk0p2 rw" \
	-m 512 -net nic -net user,hostfwd=tcp::2222-:22 -snapshot
sleep 20

$ssh "echo 'Server = http://mirror.studio-connect.de/$version/armv7h/\$repo' > /etc/pacman.d/mirrorlist"

echo "### Install requirements ###"
$ssh "pacman-db-upgrade"
$ssh "yes | pacman -Scc"
$ssh "$pacman -Syu"
$ssh "pacman-db-upgrade"
$ssh "$pacman -S git vim ntp nginx aiccu python2 python2-distribute avahi wget"
$ssh "$pacman -S python2-virtualenv alsa-plugins alsa-utils gcc make redis sudo fake-hwclock"
$ssh "$pacman -S python2-numpy ngrep tcpdump lldpd"
$ssh "$pacman -S spandsp gsm celt"
$ssh "$pacman -S hiredis libmicrohttpd"
$ssh "yes | pacman -S linux-am33x"

echo "### Install build requirements ###"
$ssh "$pacman -S base-devel"

$ssh "git clone https://github.com/Studio-Link/PKGBUILDs.git /tmp/PKGBUILDs"
$ssh "chown -R nobody /tmp/PKGBUILDs"
$ssh "echo -e 'root ALL=(ALL) ALL\nnobody ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers"

echo "### Build ###"
$ssh "echo 'MAKEFLAGS=\"-j2\"' >> /etc/makepkg.conf"
makepkg="sudo -u nobody makepkg --force --install --noconfirm --syncdeps"
$ssh "cd /tmp/PKGBUILDs/opus; $makepkg"
$ssh "cd /tmp/PKGBUILDs/jack2; $makepkg"
$ssh "cd /tmp/PKGBUILDs/libre; $makepkg"
$ssh "cd /tmp/PKGBUILDs/librem; $makepkg"
$ssh "cd /tmp/PKGBUILDs/baresip; $makepkg"
#$ssh "cd /tmp/PKGBUILDs/jack_capture; $makepkg"
#$ssh "cd /tmp/PKGBUILDs/aj-snapshot; $makepkg"
#$ssh "cd /tmp/PKGBUILDs/jack_gaudio; $makepkg"
#$ssh "cd /tmp/PKGBUILDs/darkice; $makepkg"

echo "### Download all packages ###"
$ssh "pacman -Qq > /tmp/packages"
$ssh "bash -c \"pacman --noconfirm --force -Sw \$(cat /tmp/packages|tr '\n' ' ')\"" || true
$ssh "repo-add /root/studio-link.db.tar.gz /var/cache/pacman/pkg/*.pkg.tar.xz"

mkdir -p /var/www/$version
rm -f /var/www/$version/*.tar.gz
$scp/var/cache/pacman/pkg/*.pkg.tar.xz /var/www/$version/
$scp/root/studio-link.db.tar.gz /var/www/$version/
