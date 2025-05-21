#!/bin/bash

lmstudio_initialize() {
  if test -z "$CLIGPT_API_BASE"; then
    CLIGPT_API_BASE="http://localhost:1234"
  fi
}

lmstudio_api() {
  http_json "$CLIGPT_API_BASE" '.error.message' '.error.type' "$@"
}

lmstudio_mime() {
  case "$CLIGPT_FILE" in
    *://*)
      ;;
    *.jpg|*.jpeg)
      printf 'image/jpeg'
      ;;
    *.png)
      printf 'image/png'
      ;;
    *.webp)
      printf 'image/webp'
      ;;
    *.gif)
      printf 'image/gif'
      ;;
    *)
      return 1
      ;;
  esac
}

lmstudio_test() {
  lmstudio_api v1/models '.' 1>/dev/null
}

lmstudio_messages() {
  if test -n "$CLIGPT_FILE"; then
    local mime_type
    mime_type="$(lmstudio_mime "$CLIGPT_FILE")"
    if test $? -ne 0; then
      echo "ERROR: only JPEG, PNG, WEBP and GIF is supported" >&2
      return 1
    fi

    if test -n "$mime_type"; then
      echo "Attaching $mime_type file $CLIGPT_FILE" >&2
    else
      echo "Attaching URL $CLIGPT_FILE" >&2
    fi
  fi

  local content="[]"
  content="$(additem "$content" "$(printf '{"type":"text","text":%s}' "$(tojson "$2")")")"
  printf '[{"role":"%s","content":%s}]' "$1" "$content"
}

lmstudio() {
  lmstudio_initialize
  case "$1" in
    test)
      lmstudio_test
      ;;
    models)
      lmstudio_api v1/models '.data | map("  - \(.id)\n      by: \(.owned_by)")'
      ;;
    messages)
      shift
      lmstudio_messages "$@"
      ;;
    chat/completions)
      shift

      local prompts="$1"
      local body="{}"

      body="$(setitem "$body" "stream" "false")"

      if test -n "$CLIGPT_MODEL"; then
        body="$(setitem "$body" "model" "$(tojson "$CLIGPT_MODEL")")"
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
  info="$(setitem "$info" "base" "$(tojson "$CLIGPT_API_BASE")")"

  printf '%s' "$info"
}
