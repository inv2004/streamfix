import unittest

import streamfix

let s = readLines("tests/test2.fix",5)

test "fixstr1 field":
  var f = initFix(s[0])
  check "FIX.4.2" == f.tag(8)

