#!/bin/bash

ollama() {
  return
}

platform_info() {
  info="{}"
  info="$(setitem "$info" "description" "$(tojson "Use Ollama chat completions API")")"
  info="$(setitem "$info" "fn" "$(tojson "ollama")")"
  info="$(setitem "$info" "key" "$(tojson "OLLAMA")")"
  info="$(setitem "$info" "base" "$(tojson "http://localhost:11434")")"

  printf '%s' "$info"
}
