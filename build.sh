#!/bin/sh


git checkout 1_28_stable
make clean
rm -rf _install
cp config .config
make oldconfig
make
make install
cd _install
mkdir proc sys dev etc etc/init.d
touch etc/init.d/rcS
chmod +x etc/init.d/rcS
cat <<EOM >"etc/init.d/rcS"
#!/bin/sh

echo =============================
echo PID=\$\$
echo =============================

mount -t proc none /proc
mount -t sysfs none /sys
mount -t debugfs none /sys/kernel/debug
/sbin/mdev -s

mount -t 9p -o trans=virtio rootfs /root/ -oversion=9p2000.L,posixacl
exec switch_root /root /sbin/init
EOM

touch init
mv sbin/init sbin/init.sav
mv linuxrc linuxrc.sav

ln -s ../etc/init.d/rcS sbin/init
ln -s etc/init.d/rcS linuxrc
find . | cpio -o --format=newc > ../rootfs.img
