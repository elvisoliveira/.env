#!/usr/bin/env bash

curl -fsS --max-time 3 https://api.ipify.org 2>/dev/null || printf 'N/A\n'
