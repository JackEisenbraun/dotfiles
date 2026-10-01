#!/usr/bin/env bash

# Create the pipe file if it doesn't exist yet so it doesn't crash
if [ ! -p /tmp/waybar-cava ]; then
    mkfifo /tmp/waybar-cava
fi

# Define the visualizer bar pieces
BARS=(" " "▂" "▃" "▄" "▅" "▆" "▇" "█")

# Continuous read loop from the Cava pipe stream
while true; do
    if read -r line < /tmp/waybar-cava; then
        OUT=""
        # Loop through each individual value sent over the stream
        for (( i=0; i<${#line}; i++ )); do
            val="${line:$i:1}"
            # Check if it's a valid digit between 0 and 7
            if [[ "$val" =~ [0-7] ]]; then
                OUT+="${BARS[$val]}"
            fi
        done
        echo "$OUT"
    fi
done
