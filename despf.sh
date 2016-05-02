#!/bin/sh -e
##############################################################################
#
# Copyright 2015 spf-tools team (see AUTHORS)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
#     Unless required by applicable law or agreed to in writing, software
#     distributed under the License is distributed on an "AS IS" BASIS,
#     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#     See the License for the specific language governing permissions and
#     limitations under the License.
#
##############################################################################
#
# Usage: ./despf <domain_with_SPF_TXT_record>

test -n "$DEBUG" && set -x

# Check for required tools
for cmd in dig awk grep sed cut
do
  type $cmd >/dev/null
done

a="/$0"; a=${a%/*}; a=${a#/}; a=${a:-.}; BINDIR=$(cd $a; pwd)
. $BINDIR/include/global.inc.sh
. $BINDIR/include/despf.inc.sh

# Read DNS_TIMEOUT if spf-toolsrc is present
test -r $SPFTRC && . $SPFTRC

loopfile=$(mktemp /tmp/despf-loop-XXXXXXX)
echo random-non-match-tdaoeinthaonetuhanotehu > $loopfile
trap "cleanup $loopfile; exit 1;" INT QUIT

usage() {
    cat <<-EOF
	Usage: despf.sh [OPTION]... [DOMAIN]...
	Decompose SPF records of a DOMAIN, sort and unique them.

	Available options:
	  -h                         display this help and exit
	EOF
    exit 1
}

test "$#" -gt 0 || usage
while getopts "h-" opt; do
  case $opt in
    *) usage;;
  esac
done

domain=${*:-'orig.spf-tools.ml'}

despfit "$domain" $loopfile | grep . || { cleanup $loopfile; exit 1; }
cleanup $loopfile
