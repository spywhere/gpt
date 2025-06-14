#!/bin/bash

describe_context_commands() {
  test_should_show_help_menu() {
    echo "/help" | combined_gpt -c
    expect all to match pattern
  }
}
