#!/bin/bash

ollama_initialize() {
  if test -n "$CLIGPT_API_BASE"; then
    CLIGPT_OLLAMA_API_BASE="$CLIGPT_API_BASE"
  elif test -z "$CLIGPT_OLLAMA_API_BASE"; then
    CLIGPT_OLLAMA_API_BASE="http://localhost:11434"
  fi
}

ollama() {
  ollama_initialize
  case "$1" in
    test)
      ;;
    *)
      return 1
      ;;
  esac
}

platform_info() {
  ollama_initialize 2>/dev/null

  info="{}"
  info="$(setitem "$info" "description" "$(tojson "Use Ollama chat completions API")")"
  info="$(setitem "$info" "fn" "$(tojson "ollama")")"
  info="$(setitem "$info" "key" "$(tojson "OLLAMA")")"
  info="$(setitem "$info" "base" "$(tojson "$CLIGPT_OLLAMA_API_BASE")")"

  printf '%s' "$info"
}
