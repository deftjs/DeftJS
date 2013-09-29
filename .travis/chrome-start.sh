#!/bin/bash

USER_DIR=/tmp/google-chrome

rm -rf $USER_DIR
mkdir -p $USER_DIR"/Default"

google-chrome "$CMD" --user-data-dir="$USER_DIR" --no-default-browser-check --no-first-run --disable-default-apps "$@"
