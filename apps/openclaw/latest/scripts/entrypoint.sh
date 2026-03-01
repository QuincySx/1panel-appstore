#!/bin/bash

# Load gateway token from file if not set via environment
if [ -z "$OPENCLAW_GATEWAY_TOKEN" ] && [ -f "$HOME/.openclaw/.gateway_token" ]; then
    export OPENCLAW_GATEWAY_TOKEN=$(cat "$HOME/.openclaw/.gateway_token")
fi

BIND_MODE="${OPENCLAW_GATEWAY_BIND:-lan}"

# For non-loopback bind modes, enable host header origin fallback
# This is safe because access is already protected by gateway token authentication
if [ "$BIND_MODE" != "loopback" ]; then
    SETTINGS_FILE="$HOME/.openclaw/settings.json"
    if [ ! -f "$SETTINGS_FILE" ]; then
        echo '{}' > "$SETTINGS_FILE"
    fi
    # Merge the required gateway setting using Node.js (available in the base image)
    node -e "
        const fs = require('fs');
        const path = '$SETTINGS_FILE';
        let settings = {};
        try { settings = JSON.parse(fs.readFileSync(path, 'utf8')); } catch(e) {}
        if (!settings.gateway) settings.gateway = {};
        if (!settings.gateway.controlUi) settings.gateway.controlUi = {};
        settings.gateway.controlUi.dangerouslyAllowHostHeaderOriginFallback = true;
        fs.writeFileSync(path, JSON.stringify(settings, null, 2));
    "
fi

exec openclaw gateway --allow-unconfigured --bind "$BIND_MODE" --port 18789
