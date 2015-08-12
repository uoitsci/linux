#!/usr/bin/env bash
#
# Sets the minion ID to a unique value.
#
# Author:  Richard Drake <richard.drake@uoit.ca>
#

source ./util.sh

# Make sure the script is being run as root.
util::require_root

# Check to see if the hostname has already been set.
# (Check to see if id: has been set in /etc/salt/minion.)
