#!/bin/bash
set -euxo pipefail

# https://necromuralist.github.io/posts/enabling-wake-on-lan/
INTERFACE=$(nmcli device status | grep ethernet | awk '{print $1}')

if [ -z "$INTERFACE" ]; then exit 10; fi

sudo bash -c "cat >/etc/systemd/system/wol.service" <<EOF
[Unit]
Description=Enable Wake On Lan

[Service]
Type=oneshot
ExecStart = /sbin/ethtool --change $INTERFACE wol g

[Install]
WantedBy=basic.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable wol.service
