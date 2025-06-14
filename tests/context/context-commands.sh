#!/bin/bash

describe_context_commands() {
  test_should_show_help_menu() {
    printf '/help\n' | combined_gpt -c
    expect all to match pattern
  }

  test_should_show_current_context() {
    printf '/info\n' | combined_gpt -c
    expect all to match pattern
  }

  test_should_undo_last_conversation() {
    printf 'hello\nhow are you\n/dump\n/undo\n/dump\n' | combined_gpt -c
    expect all to match pattern
  }

  test_should_clear_all_conversation() {
    printf 'hello\nhow are you\n/dump\n/clear\n/dump\n' | combined_gpt -c
    expect all to match pattern
  }
}
