#!/bin/bash
mv webmanifest.service /etc/systemd/system
systemctl daemon-reload
systemctl enable --now webmanifest