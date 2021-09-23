#!/bin/bash
cp webmanifest.service /etc/systemd/system
systemctl daemon-reload
systemctl enable --now webmanifest