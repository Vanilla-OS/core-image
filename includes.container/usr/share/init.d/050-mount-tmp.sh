#!/bin/bash

echo "Mounting tmpfs in /tmp"
mount mount -t tmpfs -o nodev,nosuid,mode=1777 tmpfs /tmp
