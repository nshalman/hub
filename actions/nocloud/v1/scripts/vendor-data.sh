#!/bin/bash

# Pass in metadata file as argument
metadata_file=$1

if [[ -z ${metadata_file} ]] || [[ ! -f "${metadata_file}" ]]; then
    echo "provide metadata file as argument"
    exit 1
fi

## Obtain required variables:
# hashed_passwd
# ssh_authorized_keys
# phone_home_url
os=`jq -r '.metadata.instance.operating_system.slug' $metadata_file`
password_hash=`jq -r '.metadata.instance.password_hash' $metadata_file`
phone_home_url=`jq -r '.metadata.instance.phone_home_url' $metadata_file`
ssh_keys=`jq '.metadata.instance.ssh_keys' $metadata_file`

# Set default user

pw_user="root"
if [[ ${os} =~ vmware_nsx_3_0_0 ]]; then
	pw_user="admin"
fi

# Output file contents
cat <<EOF
#cloud-config
users:
   - default
   - name: ${pw_user}
     lock_passwd: false
     hashed_passwd: ${password_hash}
     ssh_authorized_keys:
EOF
jq -c -r '.metadata.instance.ssh_keys[]' $metadata_file | while read i; do
cat <<EOF
      - $i
EOF
done
cat <<EOF

phone_home:
  url: $phone_home_url
EOF
