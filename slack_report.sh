#!/bin/bash
set -e

OAUTH_TOKEN="<FIXME>"

if [[ $# -eq 0 ]]; then
    echo "Error: Message argument not provided."
    # never fail
    exit 0
fi

CHANNEL="#op-erigon-mainnet-bedrock-migration"
MESSAGE="$1"

# never fail
curl -s -X POST -H "Authorization: Bearer $OAUTH_TOKEN" \
     -H 'Content-type: application/json' \
     -d "{'channel': '$CHANNEL', 'text': '$MESSAGE'}" \
     https://slack.com/api/chat.postMessage || true
