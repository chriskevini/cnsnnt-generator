#!/usr/bin/env bash

awk -v trigger_key="" '
BEGIN {
  print "matches:"
}
{
  original_word = $1
  trigger_list = ""

  for (i = 2; i <= NF; i++) {
    trigger_list = trigger_list "\"" $i trigger_key "\""
    if (i < NF) {
        trigger_list = trigger_list ", "
    }
  }

  print "  - triggers: ["trigger_list"]"
  print "    replace: \""original_word"\""
  print "    word: true"
  print "    propagate_case: true"
}
'
