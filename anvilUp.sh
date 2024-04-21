#!/bin/bash

# Stop any existing Redis instances gracefully
redis-cli shutdown

# Start a new ephemeral Redis instance if not running
redis-cli ping || redis-server --save "" --appendonly no --daemonize yes

# Start anvil in the background
anvil &

# Get the PID of the anvil process
ANVIL_PID=$!

# Store the PID in Redis
redis-cli SET anvil_pid $ANVIL_PID

echo "Anvil started with PID $ANVIL_PID and stored in Redis"

# Continue with the rest of the script
# Step 1: Delete addresses.json if it exists
rm -f addresses.json

# Step 2: Deploy contracts and update addresses.json
forge script script/DeployContracts.s.sol --broadcast --rpc-url=http://localhost:8545 --json | jq -r '.[] | .name + ":" + .address' >> addresses.json

# Step 3: Run a Node.js script to read addresses.json and update Redis
node updateRedis.js
