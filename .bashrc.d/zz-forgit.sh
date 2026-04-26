forgit_plugin="${FORGIT_HOME:-$HOME/.local/share/forgit}/forgit.plugin.sh"

if [ -r "$forgit_plugin" ]; then
  source "$forgit_plugin"
fi

unset forgit_plugin
