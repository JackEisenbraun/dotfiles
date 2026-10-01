#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════
#  Waybar helper scripts
#  Place these at ~/.config/waybar/scripts/ and chmod +x each one.
# ═══════════════════════════════════════════════════════════════════════════

# ─── gpu.sh ────────────────────────────────────────────────────────────────
# Outputs GPU utilization % for #custom-gpu
# NVIDIA version (uses nvidia-smi):
#
# #!/usr/bin/env bash
# UTIL=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null | head -1 | tr -d ' ')
# TEMP=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null | head -1)
# MEM_USED=$(nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits 2>/dev/null | head -1 | tr -d ' ')
# MEM_TOTAL=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits 2>/dev/null | head -1 | tr -d ' ')
# echo "${UTIL}"
# echo "GPU ${UTIL}% | ${TEMP}°C | ${MEM_USED}/${MEM_TOTAL} MiB"   # tooltip line
#
# AMD version (uses radeontop or /sys):
#
# #!/usr/bin/env bash
# UTIL=$(cat /sys/class/drm/card0/device/gpu_busy_percent 2>/dev/null || echo "?")
# echo "${UTIL}"

# ─── layout.sh ─────────────────────────────────────────────────────────────
# Outputs current Hyprland layout for the active workspace
#
# #!/usr/bin/env bash
# LAYOUT=$(hyprctl activewindow -j 2>/dev/null | jq -r '.fullscreen // "tiling"')
# WORKSPACE=$(hyprctl activeworkspace -j 2>/dev/null | jq -r '.id')
# # You can map layout IDs to icons just like YASB layout_icons:
# #   bsp → , columns → , rows → , monocle → 󰘖, floating → 
# echo " ${LAYOUT}"

# ─── cava.sh ───────────────────────────────────────────────────────────────
# Streams cava output as bar characters for #custom-cava.
# Requires cava. Add this to your cava config (~/.config/cava/config):
#
#   [output]
#   method = raw
#   raw_target = /tmp/waybar-cava
#   data_format = ascii
#   ascii_max_range = 7
#   bar_delimiter = 0
#
# Then run:
#
# #!/usr/bin/env bash
# BARS=("▁" "▂" "▃" "▄" "▅" "▆" "▇" "█")
# while IFS= read -r -d '' line; do
#   OUT=""
#   for byte in $(echo "$line" | od -An -tu1 | tr -s ' '); do
#     OUT+="${BARS[$byte]}"
#   done
#   echo "$OUT"
# done < /tmp/waybar-cava
#
# Simpler alternative — pipe cava stdout directly:
# cava | sed -u 's/[^▁▂▃▄▅▆▇█]//g'

# ─── wallpaper.sh ──────────────────────────────────────────────────────────
# Cycles wallpapers from a directory (mirrors YASB wallpapers widget).
# Requires swww or hyprpaper.
#
# #!/usr/bin/env bash
# WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
# if [[ "$1" == "--random" ]]; then
#   IMG=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.png" \) | shuf -n1)
# else
#   # Pick next wallpaper alphabetically
#   CURRENT=$(swww query | grep -oP '(?<=image: ).*' | head -1)
#   IMG=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.png" \) | sort | \
#         awk -v cur="$CURRENT" 'found{print;exit} $0==cur{found=1} END{if(!found)print FILENAME}' || \
#         find "$WALLPAPER_DIR" -type f | sort | head -1)
# fi
# swww img "$IMG" --transition-type slide --transition-direction top
# # Run pywal if desired:
# # wal -s -t -e -q -n -i "$IMG"

# ─── power-menu.sh ─────────────────────────────────────────────────────────
# Simple power menu using wofi (mirrors YASB power_menu widget).
# Buttons: Lock | Sleep | Restart | Hibernate | Shutdown | Cancel
#
# #!/usr/bin/env bash
# CHOICE=$(printf " Lock\n󰤄 Sleep\n󰜉 Restart\n Hibernate\n󰐥 Shut Down\n Cancel" \
#   | wofi --dmenu --prompt="Power" --width=200 --height=220 \
#          --style="$HOME/.config/waybar/scripts/power-menu.css")
# case "$CHOICE" in
#   " Lock")        loginctl lock-session ;;
#   "󰤄 Sleep")      systemctl suspend ;;
#   "󰜉 Restart")    systemctl reboot ;;
#   " Hibernate")  systemctl hibernate ;;
#   "󰐥 Shut Down") systemctl poweroff ;;
# esac

# ─── pomodoro.sh ───────────────────────────────────────────────────────────
# Minimal stateful Pomodoro timer (mirrors YASB pomodoro widget).
# State stored in /tmp/waybar-pomodoro
# Work: 25min | Short break: 5min | Long break: 15min every 4 sessions
#
# #!/usr/bin/env bash
# STATE_FILE="/tmp/waybar-pomodoro"
# WORK=1500; SHORT=300; LONG=900; INTERVAL=4
#
# load() {
#   if [[ -f "$STATE_FILE" ]]; then source "$STATE_FILE"
#   else STATUS="stopped"; REMAINING=$WORK; SESSION=0; TOTAL=8; START=0; fi
# }
# save() { echo "STATUS=$STATUS; REMAINING=$REMAINING; SESSION=$SESSION; TOTAL=$TOTAL; START=$START" > "$STATE_FILE"; }
#
# case "$1" in
#   status)
#     load
#     if [[ "$STATUS" == "running" ]]; then
#       ELAPSED=$(( $(date +%s) - START ))
#       REMAINING=$(( REMAINING - ELAPSED ))
#       START=$(date +%s)
#       [[ $REMAINING -le 0 ]] && { SESSION=$(( SESSION + 1 )); STATUS="break"; START=$(date +%s)
#         (( SESSION % INTERVAL == 0 )) && REMAINING=$LONG || REMAINING=$SHORT; }
#       save
#     fi
#     MINS=$(( REMAINING / 60 )); SECS=$(( REMAINING % 60 ))
#     [[ "$STATUS" == "running" ]] && ICON="󱎫" || ICON="󰏤"
#     [[ "$STATUS" == "break" ]] && ICON="󱎫"
#     printf "%s %02d:%02d" "$ICON" "$MINS" "$SECS"
#     ;;
#   toggle)
#     load
#     if [[ "$STATUS" == "running" ]]; then STATUS="paused"
#     else STATUS="running"; START=$(date +%s); fi
#     save ;;
#   reset)
#     echo "STATUS=stopped; REMAINING=$WORK; SESSION=0; TOTAL=8; START=0" > "$STATE_FILE" ;;
#   skip)
#     load; SESSION=$(( SESSION + 1 )); STATUS="running"; START=$(date +%s)
#     (( SESSION % INTERVAL == 0 )) && REMAINING=$LONG || REMAINING=$SHORT
#     save ;;
# esac

echo "# Copy each section above into its own script file under ~/.config/waybar/scripts/"
echo "# Then: chmod +x ~/.config/waybar/scripts/*.sh"
