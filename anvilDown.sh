#!/bin/bash

# Retrieve the PID from Redis
ANVIL_PID=$(redis-cli GET anvil_pid)

if [ -z "$ANVIL_PID" ]; then
    echo "No anvil PID found in Redis."
    exit 1
fi

# Kill the anvil process using the PID
kill $ANVIL_PID

if [ $? -eq 0 ]; then
    echo "Anvil process $ANVIL_PID has been stopped."
    # Optionally, clear the PID from Redis after stopping
    redis-cli DEL anvil_pid
else
    echo "Failed to stop Anvil process $ANVIL_PID."
fi
