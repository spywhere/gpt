#!/bin/bash

describe_basic_error() {
  test_no_prompt() {
    gpt
    expect error to match
    expect no output
  }
}
