#!/bin/bash
# Control the Roku from a computer on the same Wi-Fi (Roku's official ECP and dev installer).
#   export ROKU_IP=192.168.x.x            # shown on the TV in developer mode
#   export ROKU_DEV_PASSWORD=...          # only for "install"; never commit or paste it in chat
#   tools/tv.sh install                   # upload dist/PureTV.zip
#   tools/tv.sh open                      # open PureTV
#   tools/tv.sh key Home|Back|Up|Down|Left|Right|Select|Play
#   tools/tv.sh launch 12                 # open an app by id (12 = Netflix)
#   tools/tv.sh apps                      # list installed apps and their ids
set -euo pipefail
: "${ROKU_IP:?set ROKU_IP to the TV IP address}"
ecp="http://$ROKU_IP:8060"
case "${1:-}" in
  install) curl -sS --digest -u "rokudev:${ROKU_DEV_PASSWORD:?set ROKU_DEV_PASSWORD}" \
             -F mysubmit=Install -F "archive=@$(dirname "$0")/../dist/PureTV.zip" \
             "http://$ROKU_IP/plugin_install" | grep -o '<font color="red">[^<]*' | sed 's/.*>//' ;;
  open)    curl -sS -X POST "$ecp/launch/dev" ;;
  key)     curl -sS -X POST "$ecp/keypress/${2:?which key}" ;;
  launch)  curl -sS -X POST "$ecp/launch/${2:?app id}" ;;
  apps)    curl -sS "$ecp/query/apps" | sed -E 's#<app id="([0-9a-z_]+)"[^>]*>([^<]*)</app>#\1  \2#' | grep -v '^<' ;;
  *)       sed -n '2,10p' "$0"; exit 1 ;;
esac
