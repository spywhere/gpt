#!/bin/bash

openai_initialize() {
  if test -n "$OPENAI_API_BASE"; then
    echo "WARNING: OPENAI_API_BASE is deprecated, use CLIGPT_API_BASE instead" >&2
    CLIGPT_API_BASE="$OPENAPI_API_BASE"
  elif test -z "$CLIGPT_API_BASE"; then
    CLIGPT_API_BASE="https://api.openai.com/v1"
  fi

  if test -n "$OPENAI_API_KEY"; then
    echo "WARNING: OPENAI_API_KEY is deprecated, use CLIGPT_API_AUTHORIZATION instead" >&2
    CLIGPT_API_AUTHORIZATION="Bearer $OPENAI_API_KEY"
  fi
}

openai_mime() {
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

openai_test() {
  if test -z "$CLIGPT_API_AUTHORIZATION"; then
    echo "ERROR: CLIGPT_API_AUTHORIZATION is required" >&2
    return 1
  fi
}

openai_api() {
  http_json "$CLIGPT_API_BASE" '.error.message' '.error.type' "$@"
}

openai_messages() {
  if test -n "$CLIGPT_FILE"; then
    local mime_type
    mime_type="$(openai_mime "$CLIGPT_FILE")"
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

openai() {
  openai_initialize 2>/dev/null
  case "$1" in
    test)
      openai_test
      ;;
    models)
      openai_api models '.data | map({ id: .id, by: .owned_by })'
      ;;
    messages)
      shift
      openai_messages "$@"
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

      openai_api chat/completions "$body" '.choices[] | { role: .message.role, content: .message.content }'
      ;;
    *)
      return 1
      ;;
  esac
  return $?
}

platform_info() {
  openai_initialize

  local info="{}"
  info="$(setitem "$info" "description" "$(tojson "Use OpenAI chat completions API, required a valid API key to be set through CLIGPT_API_AUTHORIZATION")")"
  info="$(setitem "$info" "fn" "$(tojson "openai")")"
  info="$(setitem "$info" "base" "$(tojson "$CLIGPT_API_BASE")")"

  printf '%s' "$info"
}
