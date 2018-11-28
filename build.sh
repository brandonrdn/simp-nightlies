#!/bin/sh
. ./common.sh
ruby "$(pwd)/build.rb"
exit $?
