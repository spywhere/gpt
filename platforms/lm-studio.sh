#!/bin/bash

lmstudio_initialize() {
  if test -n "$CLIGPT_API_BASE"; then
    CLIGPT_LMSTUDIO_API_BASE="$CLIGPT_API_BASE"
  elif test -z "$CLIGPT_LMSTUDIO_API_BASE"; then
    CLIGPT_LMSTUDIO_API_BASE="http://localhost:1234"
  fi

  if test -n "$CLIGPT_MODEL"; then
    CLIGPT_LMSTUDIO_MODEL="$CLIGPT_MODEL"
  fi
}

lmstudio_api() {
  http_json "$CLIGPT_LMSTUDIO_API_BASE" '.error.message' '.error.type' "$@"
}

lmstudio_test() {
  lmstudio_api v1/models '.' 1>/dev/null
}

lmstudio_message() {
  printf '{"role":"%s","content":%s}' "$1" "$(tojson "$2")"
}

lmstudio() {
  lmstudio_initialize
  case "$1" in
    test)
      lmstudio_test
      ;;
    models)
      lmstudio_api v1/models '.data | map({ id: .id, by: .owned_by })'
      ;;
    message)
      lmstudio_message "$@"
      ;;
    chat/completions)
      shift

      local prompts="$1"
      local body="{}"

      body="$(setitem "$body" "stream" "false")"

      if test -n "$CLIGPT_LMSTUDIO_MODEL"; then
        body="$(setitem "$body" "model" "$(tojson "$CLIGPT_LMSTUDIO_MODEL")")"
      fi
      if test -n "$CLIGPT_TOKEN"; then
        body="$(setitem "$body" "max_tokens" "$CLIGPT_TOKEN")"
      fi
      if test -n "$CLIGPT_TEMP"; then
        body="$(setitem "$body" "temperature" "$CLIGPT_TEMP")"
      fi

      body="$(setitem "$body" "messages" "$prompts")"

      lmstudio_api v1/chat/completions "$body" '.choices[] | { role: .message.role, content: .message.content }'
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
