#!/bin/bash

# Load gateway token from file if not set via environment
if [ -z "$OPENCLAW_GATEWAY_TOKEN" ] && [ -f "$HOME/.openclaw/.gateway_token" ]; then
    export OPENCLAW_GATEWAY_TOKEN=$(cat "$HOME/.openclaw/.gateway_token")
fi

BIND_MODE="${OPENCLAW_GATEWAY_BIND:-lan}"

exec openclaw gateway --allow-unconfigured --bind "$BIND_MODE" --port 18789
