#!/usr/bin/env bash

set -euox pipefail
sudo -v || exit 1

yay -S clockify-desktop --needed --noconfirm

# Since 2.7.x the app zooms itself by round(0.8*screen_height)/640 (1.8x on a
# 1440p screen) whenever the display is >=1080 px and unscaled, in both the
# main and the renderer process. Raising the threshold out of reach is the only
# way out: the CLI flags are overridden by the app's own appendSwitch calls.
# ">=9999" is the same byte length as ">=1080", so the asar offsets still hold.
sudo install -Dm755 /dev/stdin /usr/local/bin/clockify-unzoom <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
sed -i 's/>=1080/>=9999/g' /opt/Clockify/resources/app.asar
EOF

sudo install -Dm644 /dev/stdin /etc/pacman.d/hooks/clockify-unzoom.hook <<'EOF'
[Trigger]
Operation = Install
Operation = Upgrade
Type = Path
Target = opt/Clockify/resources/app.asar

[Action]
Description = Disabling Clockify self-zoom...
When = PostTransaction
Exec = /usr/local/bin/clockify-unzoom
EOF

sudo /usr/local/bin/clockify-unzoom
