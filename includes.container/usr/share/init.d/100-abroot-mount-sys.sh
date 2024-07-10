#!/bin/bash

abroot mount-sys 2> /dev/kmsg
if [[ "$?" -ne 0 ]]; then
  exit 1
fi
