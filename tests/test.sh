#!/bin/bash

testing() {
  case "$1" in
    test)
      echo "Testing system" >&2
      ;;
    models)
      parsejson '["test-model", "another-model"]' 'map("  - \(.)")'
      ;;
    messages)
      shift
      printf '[{"role":%s,"content":%s}]' "$(tojson "$1")" "$(tojson "$2")"
      ;;
    chat/completions)
      shift
      printf '{ "role": "assistant", "content": %s }' "$(tojson "$(printf "model[%s] max_tokens[%s] temp[%s]\nprompt[%s]" "$CLIGPT_MODEL" "$CLIGPT_TOKEN" "$CLIGPT_TEMPERATURE" "$1")")"
      ;;
    *)
      return 1
      ;;
  esac
  return $?
}

platform_info() {
  local info="{}"
  info="$(setitem "$info" "description" "$(tojson "Testing platform, internal use only")")"
  info="$(setitem "$info" "fn" "$(tojson "testing")")"
  info="$(setitem "$info" "base" "$(tojson "$CLIGPT_API_BASE")")"

  printf '%s' "$info"
}
