#!/bin/bash

log() {
  local level="$1"
  local message="$2"
  echo "[abroot-unlock-var] ($level): $message"
  echo "[abroot-unlock-var] ($level): $message" > /dev/kmsg
}

graphicalpwd() {
  local varunlockcmd="$1"

  plymouth --ping
  if [[ "$?" -ne 0 ]]; then
    /usr/sbin/plymouthd
  fi

  plymouth --show-splash

  plymouth ask-for-password --prompt="Please enter passphrase to unlock your data." --command="$varunlockcmd" 2> /dev/kmsg
  if [[ "$?" -ne 0 ]]; then
    plymouth --quit
    log "warning" "falling back to cli password entry"
    clipwd
    return
  fi
}

clipwd() {
  local varunlockcmd="$1"

  $varunlockcmd
}

/lib/systemd/systemd-udevd --daemon

deviceName=""

if [ -L "/dev/disk/by-label/vos-var" ]; then
  # var drive is not encrypted, just continue
  exit 0
else
  if [ -L "/dev/mapper/vos--var-var" ]; then
    # var is encrypted LV
    deviceName="/dev/mapper/vos--var-var"
  elif [ -L "/dev/disk/by-partlabel/vos-var" ]; then
    # var is encrypted regular partition
    deviceName="$( realpath '/dev/disk/by-partlabel/vos-var' )"
  else
    log "error" "could not find var drive"
    exit 55
  fi
fi

varunlockcmd="/usr/bin/abroot unlock-var --var-disk $deviceName"

if command -v plymouth &> /dev/null ; then
  log "info" "using plymouth password entry"
  graphicalpwd "$varunlockcmd"
  exit
else
  log "info" "using cli password entry"
  clipwd "$varunlockcmd"
  exit
fi
