#!/bin/bash
# Listens to the Pushbullet Realtime Event Stream
# https://docs.pushbullet.com/#realtime-event-stream

API_URL=https://api.pushbullet.com/v2
PROGDIR="$(cd "$( dirname "$0" )" && pwd )"
unset QUIET

info() {
        if [[ -z ${QUIET} ]]; then
                echo $@
        fi
}

err() {
        if [[ -w /dev/stderr ]]; then
                echo $@ > /dev/stderr
        else
                # /dev/stderr does not exist or is not writable
                echo $@
        fi
}

if [ ! $(which wscat) ]; then
        err "push-listener requires wscat to run. To install it run 'sudo npm install -g wscat'"
        exit 1
fi

# override default PB_CONFIG if different file or API key has been given
if [[ ! -n "$PB_CONFIG" ]] && [[ ! -n "$PB_API_KEY" ]]; then
        PB_CONFIG=~/.config/pushbullet
fi
source $PB_CONFIG > /dev/null 2>&1

# don't give warning when script is called with setup option
if [[ -z "$PB_API_KEY" ]] && [[ "$1" != "setup" ]]; then
        err -e "\e[0;33mWarning, your API key is not set.\nPlease create \"$PB_CONFIG\" with a line starting with PB_API_KEY= and your PushBullet key\e[00m"
        exit 1
fi

while read line; do
	echo $line
done < <(wscat -c wss://stream.pushbullet.com/websocket/$PB_API_KEY)

