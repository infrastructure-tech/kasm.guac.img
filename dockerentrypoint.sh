#! /bin/bash

# Get the full hostname
hostname=$(hostname)

# Extract the release name (assuming it's the first component)
# Hostnames should be like 'kasm-kasm-guac-cfc8c49f9-wqrkl' or similar, where the first 'kasm' is the release name.
release_name=$(echo "$hostname" | cut -d'-' -f1)

# Check if the release name was not extracted correctly
if [ -z "$release_name" ]; then
  echo "Failed to extract release name from hostname" >&2
  exit 1
fi

# Resolve the IP address of the kasm-proxy service using the release name
kasm_proxy_ip=$(getent hosts "$release_name-proxy" | awk '{ print $1 }')

# Check if the IP address could not be resolved
if [ -z "$kasm_proxy_ip" ]; then
  echo "Could not resolve IP for $release_name-proxy service" >&2
  exit 1
fi

# Add the resolved IP and alias to /etc/hosts
echo "$kasm_proxy_ip kasm_proxy" >> /etc/hosts

# Doesn't seem to work on kubernetes with configmap mounts.
# chown -R kasm:kasm /opt/kasm
# su kasm

sudo -u kasm /usr/sbin/guacd -f -b 0.0.0.0 -l 4822 -L debug 2>&1 | grep -v 'guacd Handler not found for ""' &

cd /gclient
sudo -u kasm npm run start