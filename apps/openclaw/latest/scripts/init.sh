#!/bin/bash

# Set correct ownership for data directories (node user uid=1000)
mkdir -p ./data/config
mkdir -p ./data/workspace
chown -R 1000:1000 ./data
