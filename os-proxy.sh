sudo mkdir /run/systemd/system/nix-daemon.service.d/
cat << EOF >/tmp/111nixdae.override.conf
[Service]
#Environment="https_proxy=socks5h://192.168.31.142:10809"
Environment="https_proxy=socks5h://127.0.0.1:10809"
Environment="no_proxy=127.0.0.1,localhost,internal.domain,my-pi,mirrors.tuna.tsinghua.edu.cn,mirror.sjtu.edu.cn,mirrors.ustc.edu.cn"
EOF
sudo mv -v /tmp/111nixdae.override.conf /run/systemd/system/nix-daemon.service.d/override.conf
sudo systemctl daemon-reload
sudo systemctl restart nix-daemon
