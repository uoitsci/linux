#!/usr/bin/env bash
#
# Common utility functions that are re-use between scripts.
#
# Author:  Richard Drake <richard.drake@uoit.ca>
#

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH

# Make sure the script is being run as root.
util::require_root() {
  if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
  fi
}

# Creates a swap file.  It will not be large enough to hibernate to,
# but hibernation is disabled in Ubuntu by default anyway.  Users
# are free to make a larger swap file to hibernate to if they wish.
util::mkswap() {
  # Defaults to /swap.
  local swap_file="${1:-/swap}"

  # Don't bother creating the swap if swap space is already defined
  # in /etc/fstab.  Odds are we created a swap partition during
  # installation.
  if grep -q swap /etc/fstab; then
    return
  fi

  # Figure out how much physical RAM is in the system, in KiB.
  local swap_size="$(grep MemTotal /proc/meminfo | \
    awk '{print $2 / 2}')"

  # Create a swap file that's half the size of RAM.
  # Doesn't work under ext3.
  #fallocate -l ${swap_size} ${swap_file}
  dd if=/dev/zero of=${swap_file} bs=1K count=${swap_size}

  # Initialize the swap file.
  mkswap ${swap_file} &>/dev/null

  # Change ownership and permissions so regular users will not be
  # able to view its contents.
  chown root:root ${swap_file}
  chmod 0600 ${swap_file}

  # Add the swap file to /etc/fstab so it will be used next boot.
  # There is no need to activate it at this time.
  echo -e "${swap_file}\t\tnone\t\tswap\tdefaults\t0\t0" >> \
    /etc/fstab
}
