# Flush history to HISTFILE after every command so kills/crashes lose nothing
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }history -a"
