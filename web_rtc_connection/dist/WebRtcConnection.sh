#!/bin/sh
printf '\033c\033]0;%s\a' WebRtcConnection
base_path="$(dirname "$(realpath "$0")")"
"$base_path/WebRtcConnection.x86_64" "$@"
