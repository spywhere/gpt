#!/bin/bash

openai() {
  return
}

platform_info() {
  info="{}"
  info="$(setitem "$info" "description" "$(tojson "Use OpenAI chat completions API, required a valid API key to be set through CLIGPT_API_AUTHORIZATION")")"
  info="$(setitem "$info" "fn" "$(tojson "openai")")"
  info="$(setitem "$info" "key" "$(tojson "OPENAI")")"
  info="$(setitem "$info" "model" "$(tojson "gpt-4o")")"
  info="$(setitem "$info" "base" "$(tojson "https://api.openai.com/v1")")"

  printf '%s' "$info"
}
