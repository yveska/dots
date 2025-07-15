#!/bin/sh

PERCENTAGE="$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)"
CHARGING="$(pmset -g batt | grep 'AC Power')"
COLOR="0xffcdd6f4"

if [ "$PERCENTAGE" = "" ]; then
  exit 0
fi

case "${PERCENTAGE}" in
  9[0-9]|100) ICON=""
  COLOR="0xffcdd6f4"
  ;;
  [6-8][0-9]) ICON=""
  ;;
  [3-5][0-9]) ICON=""
  ;;
  [1-2][0-9]) ICON=""
  COLOR="0xfff9e2af"
  ;;
  *) ICON=""
  COLOR="0xfff38ba8"
esac

if [[ "$CHARGING" != "" ]]; then
  ICON=""
  COLOR="0xffa6e3a1"
fi

# The item invoking this script (name $NAME) will get its icon and label
# updated with the current battery status
sketchybar --set "$NAME" icon="$ICON" label="${PERCENTAGE}%" label.color="$COLOR"
