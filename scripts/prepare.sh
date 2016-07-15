#!/usr/bin/env bash
# 
# Prepares a laptop for shipping to the end user.
# 
# Author:  Richard Drake <richard.drake@uoit.ca>
#

set -e

base_path="$(dirname $0)"

source ${base_path}/util.sh

util::require_root

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH

# Update package list and upgrade any packages.
apt-get update
apt-get dist-upgrade -y

# Remove items that are no longer needed or would bloat the image.
# The extra dist-upgrade and autoremove shouldn't be required, but
# apt-get seems to hold back upgrades/cleanings if they aren't run
# a couple of times.
apt-get autoremove -y
apt-get dist-upgrade -y
apt-get autoremove -y
apt-get clean -y

# Switch back to the default mirror for Canada.
sed -i 's/mirror.science.uoit.ca/ca.archive.ubuntu.com/g' \
  /etc/apt/sources.list

# Update the package listing again so users don't try to connect
# to our local mirror.
apt-get update

# The majority of users will want to continue to use the Windows
# install provided by ITS.  By default, GRUB will boot into Ubuntu.
# We must change the default entry to Windows.
sed -i 's/GRUB_DEFAULT=.*/GRUB_DEFAULT="Windows 8 (loader) (on \/dev\/sda1)"/' /etc/default/grub

# After modifying any GRUB configuration files, GRUB must be updated.
update-grub &>/dev/null

# Create a swap file.
util::mkswap

echo "Machine successfully configured!"
