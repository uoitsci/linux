#!/usr/bin/env bash
#
# Configure the Salt minion daemon.
#
# Author:  Richard Drake <richard.drake@uoit.ca>
#

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH

source ./util.sh

# Make sure the script is being run as root.
util::require_root

# If Salt is already configured, abort.
if [ -s /etc/salt/minion.d/uoit.conf ]; then
  echo "Salt minion already configured, aborting."
  exit 0
fi

# Create the minion ID.  It takes the form
#   UOST<year>-<serial>
#
#   e.g. UOST15-E7A222EA

# Stop the salt-minion daemon.
service salt-minion stop

# Create the new ID.
serial=$(dmidecode -s system-serial-number | \
  sed 's/ //g' | \
  tr '[:lower:]' '[:upper:]')
model=$(dmidecode -s system-product-name | sed 's/ /\-/g')

minion_id="UOST15-${serial:(-8)}"

# Populate the configuration file with relevant settings.  This file
# must have the extension ".conf" or Salt will ignore it.
cat <<EOF > /etc/salt/minion.d/uoit.conf
# This ID field will be used rather than the hostname.  It overrides
# the procedure normally used below.
#   http://docs.saltstack.com/en/latest/topics/tutorials/
#     walkthrough.html#minion-id-generation
id: ${minion_id}
master: nacl.science.uoit.ca
# Run the "highstate" when the minion starts.
startup_states: 'highstate'
grains:
  roles:
    - ${model}
EOF

# Regenerate new keys for Salt minion.  Taken from SO:
#   http://superuser.com/questions/695917/
#     how-to-make-salt-minion-generate-new-keys
# When the minion starts up, it should automatically reinitialize
# the files below.

# Remove the old keys.
rm -f /etc/salt/pki/minion/minion.pem
rm -f /etc/salt/pki/minion/minion.pub

# Remove the old minion ID.
cat /dev/null > /etc/salt/minion_id

service salt-minion start
