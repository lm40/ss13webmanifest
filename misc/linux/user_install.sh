#!/bin/bash
mdkir -p ~/.config/systemd/user
cp webmanifest.service ~/.config/systemd/user
loginctl enable-linger $USER
systemctl --user daemon-reload
systemctl --user enable --now webmanifest