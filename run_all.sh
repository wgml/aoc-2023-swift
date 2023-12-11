#!/bin/sh -e

swift build -c release
for d in $(seq -f "%02g" 1 25)
do
  binary="./.build/x86_64-apple-macosx/release/day$d"
  if [ -e $binary ]
  then
    eval "$binary < Inputs/day$d.txt"
  fi
done

