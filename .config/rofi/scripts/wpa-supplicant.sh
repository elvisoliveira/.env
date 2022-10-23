#!/bin/bash
pkill wpa_supplicant
pkill dhcpcd
# /etc/wpa_supplicant/wpa_supplicant-wlp3s0.conf
# ctrl_interface=/run/wpa_supplicant
# update_config=1
# network={
# 	ssid="NetworkName"
# 	psk="NetworkPassword"
# }
wpa_supplicant -B -i wlp3s0 -c /etc/wpa_supplicant/wpa_supplicant-wlp3s0.conf
dhcpcd wlp3s0
