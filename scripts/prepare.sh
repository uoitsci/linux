#!/usr/bin/env bash
# 
# Prepares a laptop for shipping to the end user.
# 
# Author:  Richard Drake <richard.drake@uoit.ca>
#

set -e

source ./util.sh

util::require_root

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH

# Update the system using a local mirror.
sed -i 's/ca.archive.ubuntu.com/mirror.science.uoit.ca/g' \
  /etc/apt/sources.list

# Enable the Canonical Partner repository.
cat <<EOF > /etc/apt/sources.list.d/partner.list
deb http://archive.canonical.com/ubuntu trusty partner
EOF

# Update package list and upgrade any packages.
apt-get update
apt-get dist-upgrade -y

# Install LibreOffice from the PPAs and some basic packages.
apt-get install libreoffice uoit-laptop-fsci

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

# Ubuntu's OEM install functionality is used to allow users to
# configure their machines after they have received them.  If
# certain values are not preseeded, users will be prompted to select
# settings such as the keyboard layout.  We set these preseed values
# so users are only prompted to create an account and name their
# machine.

# Set the keyboard layout to "us."
echo "d-i keyboard-configuration/layoutcode string us" | \
  debconf-set-selections

# Set the timezone to "America/Toronto."
echo "ubiquity time/zone string America/Toronto" | \
  debconf-set-selections

# Ask oem-config to only prompt users to create an account.
echo "oem-config oem-config/steps multiselect user" | \
  debconf-set-selections

# Tell oem-config-firstboot to automatically populate preseeded
# values.  If this is not set, users will be prompted to fill out
# every value despite them already being set.  This is also
# possible to achieve by adding "automatic-oem-config" to the boot
# parameters.
sed -i 's/automatic=$/automatic=--automatic/' \
  /etc/init/oem-config.conf

# The majority of users will want to continue to use the Windows
# install provided by ITS.  By default, GRUB will boot into Ubuntu.
# We must change the default entry to Windows.
sed -i 's/GRUB_DEFAULT=.*/GRUB_DEFAULT="Windows 8 (loader) (on \/dev\/sda1)"/' /etc/default/grub

# After modifying any GRUB configuration files, GRUB must be updated.
update-grub &>/dev/null

# Create a swap file.
util::mkswap

echo "Machine successfully configured!"
