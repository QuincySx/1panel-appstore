FROM node:24-bookworm-slim

ARG EXTRA_APT_PACKAGES=""
RUN apt-get update && \
    apt-get install -y --no-install-recommends git curl ca-certificates gh jq $EXTRA_APT_PACKAGES && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN npm install -g openclaw@latest && \
    npm cache clean --force

# Optionally install Playwright Chromium with system dependencies
ARG INSTALL_PLAYWRIGHT="false"
ENV PLAYWRIGHT_BROWSERS_PATH=/home/node/.cache/ms-playwright
RUN if [ "$INSTALL_PLAYWRIGHT" = "true" ]; then \
    npx playwright-core install --with-deps chromium && \
    chown -R node:node /home/node/.cache; \
fi

WORKDIR /home/node

ENV NODE_ENV=production
ENV HOME=/home/node

USER node

EXPOSE 18789 18790

CMD ["openclaw", "gateway", "--allow-unconfigured", "--bind", "lan", "--port", "18789"]
