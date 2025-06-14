#!/bin/bash

describe_basic_prompt() {
  test_direct_prompt() {
    gpt hello world
    expect error to match tests/specs/basic_error.txt
    expect output to match tests/specs/basic_output.txt
  }

  test_pipe_prompt() {
    echo hello world | gpt
    expect error to match tests/specs/basic_error.txt
    expect output to match tests/specs/basic_output.txt
  }
}

describe_system_prompt() {
  test_pipe_with_system_prompt() {
    echo hello world | gpt you are a helpful assistant
    expect error to match *_error.txt
    expect output to match
  }
}
