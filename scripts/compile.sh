#!/bin/sh

if ! test -d "./platforms"; then
  exit 1
fi

if test -n "$(command -v gsed)"; then
  sed() {
    gsed "$@"
  }
fi

list_checksum() {
  for platform_path in ./platforms/*.sh; do
    platform_name="$(basename "$platform_path")"
    if test "$platform_name" = '*.sh'; then
      break
    fi

    hash() {
      "$1" "./platforms/$platform_name" | cut -d' ' -f1
    }

    printf '{'
    printf '"filename":"%s",' "$platform_name"
    printf '"m":"%s",' "$(hash md5sum)"
    printf '"s1":"%s"' "$(hash sha1sum)"
    printf '}\n'
  done
}

checksum_json() {
  list_checksum | jq -sc 'map({(.filename|tostring): del(.filename)}) | add'
}

if test "$1" = "compile"; then
  cp ./gpt ./gpt.bck
  sed "s/^CLIGPT_CHECKSUM=.*$/CLIGPT_CHECKSUM='"$(checksum_json)"'/g" ./gpt.bck > ./gpt
elif test "$1" = "json"; then
  checksum_json
fi
