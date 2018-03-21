#!/usr/bin/env bash

printf "\\nRemember: this script must be sourced from shell\\n\\n\\t$ source install.sh\\n\\n"

SOURCE="${0:-BASH_SOURCE[0]}"
# resolve $SOURCE until the file is no longer a symlink
while [ -h "$SOURCE" ]; do
    DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
    SOURCE="$(readlink "$SOURCE")"
    # if $SOURCE was a relative symlink, we need to resolve it
    # relative to the path where the symlink file was located
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

if [[ ":$PATH:" != *":$DIR/bin:"* ]]; then
  if [ -d "$DIR/bin" ]; then
    export PATH="$PATH:$DIR/bin"
    printf "\\nAdding '%s/bin' directory to PATH...\\n\\nPATH=%s\\n" "$DIR" "$PATH"
  else
    printf "\\nerror: '%s/bin' directory not found!\\n" "$DIR"
    return 1
  fi
fi

printf "\\nYour path is correctly set!\\n"
return 0
