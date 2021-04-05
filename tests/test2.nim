import unittest

import streamfix

let s = readLines("tests/test2.fix",5)

test "fixstr1 field":
  var f = initFix(s[0])
  check "FIX.4.2" == f.tagStr(8)

test "fixstr1 iter":
  var f = initFix(s[4])
  check 'i' == f.tagChar(35)
  echo f.tagFloat(188)
  echo f.tagFloat(190)
