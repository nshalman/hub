FROM alpine:3.14.0
RUN apk add --update --upgrade \
    bash curl dosfstools jq parted sgdisk

COPY scripts/ /scripts/
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT /entrypoint.sh
