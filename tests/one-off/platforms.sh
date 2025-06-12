#!/bin/bash

describe_platform_listing() {
  test_should_list_all_platforms() {
    gpt --platforms
    expect no error
    expect output to match
  }
}
