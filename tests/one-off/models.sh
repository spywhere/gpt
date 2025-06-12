#!/bin/bash

describe_model_listing() {
  test_should_list_all_models() {
    gpt --models
    expect error to match *_error.txt
    expect output to match
  }
}
