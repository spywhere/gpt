#!/bin/bash

cwd="$(dirname "$0")"
root="$(dirname "$cwd")"

tempfile="$(mktemp)"
outfile="$(mktemp)"
errfile="$(mktemp)"
pending="?"
passed="P"
failed="F"

esc_reset="" # reset
esc_gray="" # indicate test name
esc_green="" # indicate passing tests
esc_red="" # indicate failing tests
esc_yellow="" # indicate variables

inline_support=0
if test -t 1 && test -n "$TERM" -a -n "$(command -v tput)" && test "$(tput colors)" -ge 8 && test -n "$(command -v tty)"; then
  pending="⏺"
  passed="✓"
  failed="✕"
  if test -n "$(command -v wc)"; then
    inline_support=1
  fi
  esc_reset="$(tput sgr0)"
  esc_gray="$(tput setaf 8)"
  if test "$(tput colors)" -gt 8; then
    esc_yellow="$(tput setaf 11)"
    esc_green="$(tput setaf 10)"
    esc_red="$(tput setaf 9)"
  else
    esc_yellow="$(tput setaf 3)"
    esc_green="$(tput setaf 2)"
    esc_red="$(tput setaf 1)"
  fi
fi

is_interactive() {
  return $(( 1 - inline_support ))
}

prettify_name() {
  echo "$2" | sed "s/^${1}_//g" | sed 's/_/ /g' | sed 's/  /_/g'
}

has_prefix() {
  case "$2" in
    ${1}_*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

loader() {
  local pid=$1
  local text="$2"
  local anim=".  .. ...   "
  local delay=0.3
  while true; do
    if ! kill -0 "$pid" 2>/dev/null; then
      printf '\r%s   \r' "$text" >&2
      break
    fi

    local char="$(echo "$anim" | cut -c1-3)"
    printf '\r%s%s' "$text" "$char" >&2
    anim="$(echo "$anim" | cut -c4-)$char"
    sleep "$delay"
  done

  wait "$pid"
  return $?
}

run_task() {
  local task="$1"
  local text="$2"
  local prefix="$3"
  if ! is_interactive; then
    "$task"
    return $?
  fi

  "$task" >"$tempfile" &
  loader "$!" "$text" "$prefix"
  local code="$?"
  cat "$tempfile"
  return "$code"
}

run_describe() {
  "__$1"
  unset -f "$1"
  local name
  name="$(prettify_name describe "$1")"
  local prefix
  prefix="$2"

  if is_interactive; then
    echo "$prefix$name"
    run_tests "$prefix  "
  else
    run_tests "$prefix$name > "
  fi
}

run_test() {
  local fn
  fn="$1"
  local name
  name="$(prettify_name test "$1")"

  TEST_FN="$(echo "$fn" | sed 's/^test_//')"
  TEST_NAME="$name"
  local response
  response="$(run_task "__$fn" "$2$pending $esc_gray$name$esc_reset")"
  if test $? -ne 0; then
    if is_interactive; then
      echo "$2$esc_red$failed $esc_gray$name$esc_reset"
      echo
      echo "$response" | sed 's/^/    /g'
      echo
    else
      echo "$2$name [$failed]"
    fi
  elif is_interactive; then
    echo "$2$esc_green$passed $esc_gray$name$esc_reset"
  else
    echo "$2$name [$passed]"
  fi
}

run_tests() {
  local prefix
  prefix="$1"
  local describes
  describes=""
  local tests
  tests=""

  while read -r raw_fn; do
    fn="$(echo "$raw_fn" | cut -d' ' -f3-)"

    if has_prefix describe "$fn"; then
      describes="$describes $fn"
    elif has_prefix test "$fn"; then
      tests="$tests $fn"
    else
      continue
    fi

    eval "$(declare -f "$fn" | sed '1s/^/__/')"
    unset -f "$fn"
  done<<<"$(declare -F)"

  for desc in $describes; do
    run_describe "$desc" "$prefix"
  done
  for testcase in $tests; do
    run_test "$testcase" "$prefix"
  done
}

gpt() {
  CLIGPT_PLATFORM=testing CLIGPT_PLATFORM_STORAGE="$root/tests/platforms" "$root/gpt" "$@" >"$outfile" 2>"$errfile"
}

match() {
  if test -z "$2"; then
    if test -z "$1"; then
      return 0
    else
      echo "Expected output to be empty, but got some content instead"
      echo
      echo "Output:"
      echo "$1" | sed "s/^/  $esc_red/" | sed "s/$/$esc_reset/"
      echo
      return 2
    fi
  fi

  output_name="$2.txt"
  if ! test -f "$output_name"; then
    echo "Expected output to match the content of $esc_yellow$output_name$esc_reset, but the file was not found"
    echo
    echo "Output:"
    if test -n "$1"; then
      echo "$1" | sed "s/^/  $esc_red/" | sed "s/$/$esc_reset/"
      echo
    else
      echo "  ${esc_gray}empty$esc_reset"
      echo
    fi
    return 2
  fi

  output="$(cat "$output_name")"

  if ! test "$1" = "$output"; then
    # TODO: Produce some output as JSON
    return 2
  fi
}

expect() {
  local input

  to_branch() {
    case "$1" in
      match)
        shift

        if test -n "$1"; then
          match "$input" "$(echo "$1" | sed "s|*|$TEST_WORKDIR/$TEST_FN|")"
        else
          match "$input" "$TEST_WORKDIR/$TEST_FN"
        fi

        return $?
        ;;
      *)
        return 1
        ;;
    esac
  }

  input_selector() {
    case "$1" in
      output)
        input="$(cat "$outfile")"
        ;;
      error)
        input="$(cat "$errfile")"
        ;;
      *)
        return 1
        ;;
    esac
  }

  action_selector() {
    case "$1" in
      to)
        shift
        to_branch "$@"
        ;;
      *)
        return 1
        ;;
    esac
  }

  prefix_branch() {
    case "$1" in
      no)
        shift
        input_selector "$@"
        shift

        match "$input"
        return $?
        ;;
      *)
        input_selector "$@"
        shift
        action_selector "$@"
        ;;
    esac
  }

  prefix_branch "$@"
}
