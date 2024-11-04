#!/bin/sh

ip=${1:-192.168.31.142}
port=${2:-10809}

echo "[Service]" > /tmp/111nixdae.override.conf.665506952
echo "Environment=\"https_proxy=socks5h://${ip}:${port}\"" >> /tmp/111nixdae.override.conf.665506952
echo "Environment=\"no_proxy=127.0.0.1,localhost,internal.domain,my-pi,mirrors.tuna.tsinghua.edu.cn,mirror.sjtu.edu.cn,mirrors.ustc.edu.cn,gitee.com\"" >> /tmp/111nixdae.override.conf.665506952
sudo mkdir /run/systemd/system/nix-daemon.service.d/
sudo mv -v /tmp/111nixdae.override.conf.665506952 /run/systemd/system/nix-daemon.service.d/override.conf
sudo systemctl daemon-reload
sudo systemctl restart nix-daemon

