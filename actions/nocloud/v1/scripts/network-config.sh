#!/bin/bash
#
# Usage: network-config.sh metadata-file
#
# Purpose: Generates a network-config version 2 config file
# that can be used with NoCloud datasource for cloud-init
#
# Author: Sarah Funkhouser <sfunkhouser@equinix.com>

# Pass in metadata file as argument
metadata_file=$1

if [[ -z ${metadata_file} ]] || [[ ! -f "${metadata_file}" ]]; then
    echo "provide metadata file as argument"
    exit 1
fi

## Obtain required variables from meta data json:
#
# interfaces
# addresses
# gateway


# FOLLOWING IS FOR DEMO ONLY
# This should be set to 802.3ad
mode="active-backup"

# Setting defaults
bond_name="bond0"
nameserver="8.8.8.8"

# Output file contents with data
cat <<EOF
version: 2
renderer: networkd
ethernets:
EOF

interfaces_path=".metadata.instance.network.interfaces"
ifaces=
for i in $(jq "$interfaces_path | keys | .[]" $metadata_file); do
  bond=$(jq -r "$interfaces_path[$i].bond" $metadata_file)

  # ensure this is bond0 before adding to the ifaces list for now
  if [[ "${bond}" == "${bond_name}" ]]; then
    iface_name=$(jq -r "$interfaces_path[$i].name" $metadata_file)
    macaddress=$(jq -r "$interfaces_path[$i].mac" $metadata_file)

    # first one should be the primary interface, which is used in active-backup mode
    if [[ ${ifaces} == "" ]]; then
      ifaces=$iface_name
      primary_interface=$iface_name
    else
      ifaces="${ifaces}, ${iface_name}"
    fi

    # add interfaces to ethernets
cat <<EOF
  ${iface_name}:
    dhcp4: no
    match:
      macaddress: ${macaddress}
EOF
  fi
done

# Add the bonds, specifically the bond0 interface
cat <<EOF
bonds:
  ${bond_name}:
      interfaces: [ ${ifaces} ]
EOF

jq -c -r '.metadata.instance.network.addresses[]' $metadata_file | while read i; do
    public=$(echo $i |jq .public)
    address_family=$(echo $i |jq .address_family)

    # Grab the public ipv4 address
    if [[ "${public}" == "true" ]] && [[ "${address_family}" == "4" ]]; then
      address=$(echo $i |jq -r .address)
      cidr=$(echo $i |jq -r .cidr)
      gateway=$(echo $i |jq -r .gateway)

# Add the address and routes
cat <<EOF
      addresses: [${address}/${cidr}]
      routes:
        - to: 0.0.0.0/0
          via: ${gateway}
EOF
    fi
  done

# Currently all defaulting to 8.8.8.8 + active-backup
cat <<EOF
      nameservers:
          addresses: [ ${nameserver} ]
      parameters:
          mode: ${mode}
EOF

if [[ "${mode}" == "active-backup" ]]; then
cat <<EOF
          primary: ${primary_interface}
EOF
fi
