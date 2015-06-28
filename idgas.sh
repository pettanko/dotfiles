#!/bin/bash

echo "edit your locale/uncomment your locale in /etc/locale.gen then run "locale-gen""

echo LANG=en_ie.UTF-8 > /etc/locale.conf
export LANG=en_ie.UTF-8
ln -s /usr/share/zoneinfo/Europe/Dublin /etc/localtime
echo Chiba > /etc/hostname

echo "Edit /etc/mkinitcpio.conf: Put “keymap”, “encrypt” and “lvm2″ (in that order!) before “filesystems” in the HOOKS array"

echo "Then  run : mkinitcpio -p linux "
