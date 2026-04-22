PB_PRIVATE_SNIPPETS_DIR="$HOME/.config/peanutbutter-private/snippets"

if [ -d "$PB_PRIVATE_SNIPPETS_DIR" ]; then
  if [ -n "$PEANUTBUTTER_PATH" ]; then
    export PEANUTBUTTER_PATH="$PEANUTBUTTER_PATH:$PB_PRIVATE_SNIPPETS_DIR"
  else
    export PEANUTBUTTER_PATH="$PB_PRIVATE_SNIPPETS_DIR"
  fi
fi

eval "$(peanutbutter --bash)"
