#!/bin/bash

wget http://download.virtualbox.org/virtualbox/5.0.24/VBoxGuestAdditions_5.0.24.iso -P /tmp

sudo mount -o loop /tmp/VBoxGuestAdditions_5.0.24.iso /mnt

sudo sh -x /mnt/VBoxLinuxAdditions.run # --keep

sudo modprobe vboxsf

sudo /opt/VBoxGuestAdditions*/init/vboxadd setup

sudo reboot
