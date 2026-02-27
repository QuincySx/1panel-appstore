#!/bin/bash

# Set correct ownership for data directories (node user uid=1000)
mkdir -p ./data/config
mkdir -p ./data/workspace

# Auto-generate gateway token if not exists (reuse existing token across restarts)
TOKEN_FILE="./data/config/.gateway_token"
if [ ! -f "$TOKEN_FILE" ]; then
    GATEWAY_TOKEN=$(openssl rand -hex 32 2>/dev/null || python3 -c "import secrets; print(secrets.token_hex(32))")
    echo "$GATEWAY_TOKEN" > "$TOKEN_FILE"
    echo "============================================"
    echo "  OpenClaw Gateway Token (auto-generated):"
    echo "  $GATEWAY_TOKEN"
    echo "============================================"
    echo "  Access dashboard at:"
    echo "  http://<server-ip>:<gateway-port>?token=$GATEWAY_TOKEN"
    echo "============================================"
else
    echo "Gateway token already exists, reusing."
fi

chown -R 1000:1000 ./data
