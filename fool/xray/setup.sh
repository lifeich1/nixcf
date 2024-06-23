#!/bin/sh
sudo cat "$1" | sudo tee /etc/systemd/system/xray.service && \
  sudo systemctl daemon-reload && \
  sudo systemctl enable xray.service && \
  sudo systemctl restart xray.service && \
  journalctl -f -u xray.service

