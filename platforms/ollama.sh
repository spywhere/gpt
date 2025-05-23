#!/bin/bash

ollama_initialize() {
  if test -z "$CLIGPT_API_BASE"; then
    CLIGPT_API_BASE="http://localhost:11434"
  fi
}

ollama_api() {
  http_json "$CLIGPT_API_BASE" '.error' - "$@"
}

ollama_test() {
  ollama_api api/version '.' 1>/dev/null
}

ollama_messages() {
  if test -n "$CLIGPT_FILE"; then
    echo "Attaching file $CLIGPT_FILE" >&2
  fi

  printf '[{"role":"%s","content":%s}]' "$1" "$(tojson "$2")"
}

ollama() {
  ollama_initialize
  case "$1" in
    test)
      ollama_test
      ;;
    models)
      ollama_api api/tags '.models | map("  - \(.name)\n      by: \(.details.family)")'
      ;;
    messages)
      shift
      ollama_messages "$@"
      ;;
    chat/completions)
      shift

      local prompts="$1"
      local body="{}"

      body="$(setitem "$body" "stream" "false")"

      if test -n "$CLIGPT_MODEL"; then
        body="$(setitem "$body" "model" "$(tojson "$CLIGPT_MODEL")")"
      fi

      if test -n "$CLIGPT_TOKEN" -o -n "$CLIGPT_TEMP"; then
        local options="{}"

        if test -n "$CLIGPT_TOKEN"; then
          options="$(setitem "$options" "num_predict" "$CLIGPT_TOKEN")"
        fi
        if test -n "$CLIGPT_TEMP"; then
          options="$(setitem "$options" "temperature" "$CLIGPT_TEMP")"
        fi

        body="$(setitem "$body" "options" "$options")"
      fi

      body="$(setitem "$body" "messages" "$prompts")"

      ollama_api api/chat "$body" '{ role: .message.role, content: .message.content }'
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
  info="$(setitem "$info" "base" "$(tojson "$CLIGPT_API_BASE")")"

  printf '%s' "$info"
}
