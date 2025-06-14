#!/bin/bash

cwd="$(dirname "$0")"

. "$cwd/lib.sh"

file_filter=""

case "$1" in
  *.sh)
    file_filter="$1"
    shift
    ;;
  *)
    ;;
esac

for name in "$cwd"/*; do
  if ! test -d "$name"; then
    continue
  fi

  if test "$(basename "$name")" = "platforms"; then
    continue
  fi

  for testfile in "$name"/*.sh; do
    if ! test -f "$testfile"; then
      continue
    fi

    if test -n "$file_filter" -a "$(basename "$testfile")" != "$file_filter"; then
      continue
    fi

    TEST_WORKDIR="$name"
    TEST_FILE="$(echo "$testfile" | sed 's/\.sh$//')"
    . "$testfile"
  done
done

if test -z "$1"; then
  run_tests --verbose
else
  run_tests --verbose --filter "$1"
fi

# describe_flags() {
#   test_help_message() {
#     return 1
#   }
#
#   test_1() {
#     return
#   }
#
#   describe_debug_flags() {
#     test_debug_mode() {
#       return
#     }
#
#     test_dry_run() {
#       return 1
#     }
#   }
# }
#
# describe_main() {
#   test_main_functionality() {
#     return
#   }
#
#   test_2() {
#     return 1
#   }
# }
#
# test_command_functionality() {
#   return 1
# }
#
# test_3() {
#   return
# }
