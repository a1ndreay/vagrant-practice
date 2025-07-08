#!/bin/bash

if dpkg -l | grep -qw python3-testinfra; then
    exit 0
else
    sudo apt update
    sudo apt install -y python3-testinfra
fi