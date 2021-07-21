#!/bin/bash

# Pass in metadata file as argument
metadata_file=$1

if [[ -z ${metadata_file} ]] || [[ ! -f "${metadata_file}" ]]; then
    echo "provide metadata file as argument"
    exit 1
fi

## Obtain required variables:
# id
# hostname
id=`jq -r '.id' $metadata_file`
hostname=`jq -r '.metadata.instance.hostname' $metadata_file`


# Output file contents
cat <<EOF
instance-id: ${id}
local-hostname: ${hostname}
EOF
