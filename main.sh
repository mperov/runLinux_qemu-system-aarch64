#!/bin/bash

sudo apt-get install qemu-utils qemu-efi-aarch64 qemu-system-arm

wget https://cdimage.debian.org/cdimage/openstack/current/debian-10-openstack-arm64.qcow2
# or wget http://cloud-images.ubuntu.com/daily/server/focal/current/focal-server-cloudimg-arm64.img

sudo modprobe nbd
sudo qemu-nbd -c /dev/nbd0 debian-10-openstack-arm64.qcow2
sudo mount /dev/nbd0p2 /mnt
su -c "ssh-add -L > /mnt/root/.ssh/authorized_keys"
sudo umount /mnt
sudo qemu-nbd -d /dev/nbd0

sudo qemu-system-aarch64 -m 2G -M virt -cpu max \
                    -bios /usr/share/qemu-efi-aarch64/QEMU_EFI.fd \
                    -drive if=none,file=debian-10-openstack-arm64.qcow2,id=hd0 \
                    -device virtio-blk-device,drive=hd0 \
                    -device e1000,netdev=net0 \
                    -netdev user,id=net0,hostfwd=tcp:127.0.0.1:10022-:22 \
                    -nographic
                    
sudo ssh -p 10022 root@localhost
