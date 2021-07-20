---
slug: configdrive
name: configdrive
tags: disk
maintainers: Nahum Shalman <nshalman@equinix.com>
description: "This action will create a configdrive partition
at the end of the specified disk"
version: v1.0.0
createdAt: "2021-07-20T17:06:15.00Z"
---

```yaml
actions:
    - name: "configdrive"
      image: quay.io/tinkerbell-actions/configdrive:v1.0.0
      timeout: 30
      environment:
          DEST_DISK: /dev/sda
```
