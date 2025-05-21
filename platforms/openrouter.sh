#!/bin/bash

openrouter_initialize() {
  if test -z "$CLIGPT_API_BASE"; then
    CLIGPT_API_BASE="https://openrouter.ai/api/v1"
  fi
}

openrouter_mime() {
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
    *.pdf)
      printf 'document/pdf'
      ;;
    *)
      return 1
      ;;
  esac
}

openrouter_test() {
  if test -z "$CLIGPT_API_AUTHORIZATION"; then
    echo "ERROR: CLIGPT_API_AUTHORIZATION is required" >&2
    return 1
  fi
}

openrouter_api() {
  http_json "$CLIGPT_API_BASE" '.error.message' - "$@"
}

openrouter_messages() {
  local content="[]"

  if test -n "$CLIGPT_FILE"; then
    local mime_type
    mime_type="$(openai_mime "$CLIGPT_FILE")"
    if test $? -ne 0; then
      echo "ERROR: only JPEG, PNG, WEBP and PDF is supported" >&2
      return 1
    fi

    if test -n "$mime_type"; then
      if test "$mime_type" = "document/pdf"; then
        echo "Attaching PDF document: $CLIGPT_FILE" >&2
        local file_data="{}"
        file_data="$(setitem "$file_data" "filename" "$(tojson "$(basename "$CLIGPT_FILE")")")"
        file_data="$(setitem "$file_data" "file_data" "$(tojson "$(base64 -i "$CLIGPT_FILE")")")"
        content="$(additem "$content" "$(printf '{"type":"file","file":%s}' "$file_data")")"
      else
        echo "Attaching image: $CLIGPT_FILE" >&2
        local image_data="$(setitem "{}" "url" "$(tojson "data:$mime_type;base64,$(base64 -i "$CLIGPT_FILE")")")"
        content="$(additem "$content" "$(printf '{"type":"image_url","image_url":%s}' "$image_data")")"
      fi
    else
      echo "Attaching URL: $CLIGPT_FILE" >&2
      local image_data="$(setitem "{}" "url" "$(tojson "$CLIGPT_FILE")")"
      content="$(additem "$content" "$(printf '{"type":"image_url","image_url":%s}' "$image_data")")"
    fi
  fi

  content="$(additem "$content" "$(printf '{"type":"text","text":%s}' "$(tojson "$2")")")"
  printf '[{"role":"%s","content":%s}]' "$1" "$content"
}

openrouter() {
  openrouter_initialize 2>/dev/null
  case "$1" in
    test)
      openrouter_test
      ;;
    models)
      openrouter_api models '.data | map("  - \(.id)\n      name: \(.name)")'
      ;;
    messages)
      shift
      openrouter_messages "$@"
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

      openrouter_api chat/completions "$body" '.choices[] | { role: .message.role, content: .message.content }'
      ;;
    *)
      return 1
      ;;
  esac
  return $?
}

platform_info() {
  openrouter_initialize

  local info="{}"
  info="$(setitem "$info" "description" "$(tojson "Use OpenRouter chat completions API, required a valid API key to be set through CLIGPT_API_AUTHORIZATION")")"
  info="$(setitem "$info" "fn" "$(tojson "openrouter")")"
  info="$(setitem "$info" "base" "$(tojson "$CLIGPT_API_BASE")")"

  printf '%s' "$info"
}
