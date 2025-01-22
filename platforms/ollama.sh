#!/bin/bash

ollama_initialize() {
  if test -n "$CLIGPT_API_BASE"; then
    CLIGPT_OLLAMA_API_BASE="$CLIGPT_API_BASE"
  elif test -z "$CLIGPT_OLLAMA_API_BASE"; then
    CLIGPT_OLLAMA_API_BASE="http://localhost:11434"
  fi

  if test -n "$CLIGPT_MODEL"; then
    CLIGPT_OLLAMA_MODEL="$CLIGPT_MODEL"
  fi
}

handle_ollama_response() {
  local response="$1"
  local errmsg
  errmsg="$(printf '%s' "$response" | jq -er '.error')"
  if test "$?" -eq 0; then
    restore_ui
    printf 'ERROR: %s\n' "$errmsg" >&2
    return 1
  fi
  return 0
}

ollama_api() {
  local path="$1"
  local body="$2"
  local filter="$3"
  local method="POST"
  if test -z "$3"; then
    body=""
    filter="$2"
    method="GET"
  elif test "$debug" -ge 1; then
    printf 'Req[%s]: %s\n' "$path" "$body" >&2
  fi
  if test "$debug" -eq 2; then
    return 4
  fi
  task() {
    curl -m "$CLIGPT_TIMEOUT" -X "$method" -d "$body" -sSL "$CLIGPT_OLLAMA_API_BASE/$path" -H 'Content-Type: application/json' 2>/dev/null
  }
  local response
  response="$(run_task task)"
  if test $? -ne 0; then
    return 1
  fi

  if test "$debug" -ge 1; then
    printf 'Res[%s]: %s\n' "$path" "$response" >&2
  fi

  parsejson "$response" '.' >/dev/null 2>&1
  if test $? -ne 0; then
    return 2
  fi

  if ! handle_ollama_response "$response"; then
    return 3
  fi

  parsejson "$response" "$filter"
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
      ollama_api api/tags '.models | map({ id: .name, by: .details.family })'
      ;;
    chat/completions)
      shift

      local prompts="$1"

      local body="{}"

      body="$(setitem "$body" "stream" "false")"

      if test -n "$CLIGPT_OLLAMA_MODEL"; then
        body="$(setitem "$body" "model" "$(tojson "$CLIGPT_OLLAMA_MODEL")")"
      fi
      if test -n "$CLIGPT_TOKEN"; then
        body="$(setitem "$body" "max_tokens" "$CLIGPT_TOKEN")"
      fi
      if test -n "$CLIGPT_TEMP"; then
        body="$(setitem "$body" "temperature" "$CLIGPT_TEMP")"
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
  info="$(setitem "$info" "key" "$(tojson "OLLAMA")")"
  info="$(setitem "$info" "base" "$(tojson "$CLIGPT_OLLAMA_API_BASE")")"

  printf '%s' "$info"
}
