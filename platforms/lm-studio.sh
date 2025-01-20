#!/bin/bash

lmstudio_initialize() {
  if test -n "$CLIGPT_API_BASE"; then
    CLIGPT_LMSTUDIO_API_BASE="$CLIGPT_API_BASE"
  elif test -z "$CLIGPT_LMSTUDIO_API_BASE"; then
    CLIGPT_LMSTUDIO_API_BASE="http://localhost:1234"
  fi
}

lmstudio_test() {
  curl -m "$CLIGPT_TIMEOUT" -X "GET" -sSL "$CLIGPT_LMSTUDIO_API_BASE/api/v0/models" -H 'Content-Type: application/json' 1>/dev/null 2>&1
}

lmstudio() {
  lmstudio_initialize
  case "$1" in
    test)
      lmstudio_test
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
  lmstudio_initialize 2>/dev/null

  local info="{}"
  info="$(setitem "$info" "description" "$(tojson "Use LM Studio chat completions API")")"
  info="$(setitem "$info" "fn" "$(tojson "lmstudio")")"
  info="$(setitem "$info" "key" "$(tojson "LMSTUDIO")")"
  info="$(setitem "$info" "base" "$(tojson "$CLIGPT_LMSTUDIO_API_BASE")")"

  printf '%s' "$info"
}
