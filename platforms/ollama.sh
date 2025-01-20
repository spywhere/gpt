#!/bin/bash

ollama_initialize() {
  if test -n "$CLIGPT_API_BASE"; then
    CLIGPT_OLLAMA_API_BASE="$CLIGPT_API_BASE"
  elif test -z "$CLIGPT_OLLAMA_API_BASE"; then
    CLIGPT_OLLAMA_API_BASE="http://localhost:11434"
  fi
}

ollama_test() {
  curl -m "$CLIGPT_TIMEOUT" -X "GET" -sSL "$CLIGPT_OLLAMA_API_BASE/api/version" -H 'Content-Type: application/json' 1>/dev/null 2>&1
}

ollama() {
  ollama_initialize
  case "$1" in
    test)
      ollama_test
      ;;
    models)
      ;;
    completions)
      ;;
    *)
      return 1
      ;;
  esac
  return $?
}

platform_info() {
  ollama_initialize 2>/dev/null

  local info="{}"
  info="$(setitem "$info" "description" "$(tojson "Use Ollama chat completions API")")"
  info="$(setitem "$info" "fn" "$(tojson "ollama")")"
  info="$(setitem "$info" "key" "$(tojson "OLLAMA")")"
  info="$(setitem "$info" "base" "$(tojson "$CLIGPT_OLLAMA_API_BASE")")"

  printf '%s' "$info"
}
