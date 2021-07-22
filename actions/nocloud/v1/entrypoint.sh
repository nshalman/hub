#!/bin/sh
set -o xtrace
set -o errexit

LABEL=cidata
MOUNTPOINT="/${LABEL}"
sgdisk --mbrtogpt --move-second-header --new 0:-256M:0 --typecode 0:0700 --change-name "0:${LABEL}" "${DEST_DISK:?}"
partprobe
#mkdosfs -F 32 -n "${LABEL}" "/dev/disk/by-partlabel/${LABEL}"
PARTITION=$(sgdisk -p "${DEST_DISK:?}" | grep "${LABEL}" | awk '{print $1}')
mkdosfs -F 32 -n "${LABEL}" "${DEST_DISK:?}${PARTITION}"

# mount the partition
mkdir "${MOUNTPOINT}"
mount LABEL="${LABEL}" "${MOUNTPOINT}"

# write out user-data
curl --fail "${METADATA_URL:?}/2009-04-04/user-data" > "${MOUNTPOINT}/user-data"

# fetch metadata from hegel
METADATA_FILE="${MOUNTPOINT}/hegel-metadata.json"
curl --fail "${METADATA_URL:?}/metadata" > "${METADATA_FILE}"

# write out remaining configdrive format files based on metadata

/scripts/meta-data.sh "${METADATA_FILE}" > "${MOUNTPOINT}/meta-data"
/scripts/vendor-data.sh "${METADATA_FILE}" > "${MOUNTPOINT}/vendor-data"
/scripts/network-config.sh "${METADATA_FILE}" > "${MOUNTPOINT}/network-config"

# unmount partition
umount "$MOUNTPOINT"
