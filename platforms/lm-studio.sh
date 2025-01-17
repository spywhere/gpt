#!/bin/bash

lmstudio() {
  return
}

platform_info() {
  info="{}"
  info="$(setitem "$info" "description" "$(tojson "Use LM Studio chat completions API")")"
  info="$(setitem "$info" "fn" "$(tojson "lmstudio")")"
  info="$(setitem "$info" "key" "$(tojson "LMSTUDIO")")"
  info="$(setitem "$info" "base" "$(tojson "http://localhost:1234")")"

  printf '%s' "$info"
}
