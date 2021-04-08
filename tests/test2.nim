import unittest

import streamfix

let s = readLines("tests/test2.fix",5)

test "fixstr1 field":
  var f = initFix(s[0])
  check "FIX.4.2" == f.getStr(BeginString.int)
  check 101 == f.getUInt(BodyLength.int)

test "fixstr1 iter":
  var f = initFix(s[4])
  check 'i' == f.getChar(MsgType.int)
  var v: string
  let gr1 = f.getGroup(GrpNoQuoteSets)
  doAssert 5 == gr1.len
  while true:
    let t = gr1.getAnyTagG([QuoteSetID.int], v)
    if 0 == t:
      break
    echo t, ": ", v
    let gr2 = f.getGroup(GrpNoQuoteEntries)
    # echo "count: ", v
    while true:
      let t = gr2.getAnyTagG([BidSpotRate.int, OfferSpotRate.int], v)
      if 0 == t:
        break
      echo t, ": ", v
  let t = f.tagAnyStr([CheckSum.int], v)
  echo t, ": ", v

# test "fixstr1 iter":
#   var f = initFix(s[4])
#   check 'i' == f.getChar(MsgType.int)
#   var v: string
#   while true:
#     if not f.tagStr(QuoteSetID.int, v):
#       break
#     discard f.tagAnyStr([NoQuoteEntries.int], v)
#     echo "302: ", v, "    count: ", v
#     while true:
#       let t = f.getAnyTagGrp(grpII, [BidSpotRate.int, OfferSpotRate.int], v)
#       if 0 == t:
#         break
#       echo t, ": ", v
#   let t = f.tagAnyStr([CheckSum.int], v)
#   echo t, ": ", v

# test "fixstr1 iter until":
#   var f = initFix(s[4])
#   check 'i' == f.getChar(MsgType.int)
#   var v: string
#   while true:
#     if not f.tagStr(QuoteSetID.int, v):
#       break
#     discard f.tagAnyStr([NoQuoteEntries.int], v)
#     echo "302: ", v, "    count: ", v
#     while true:
#       let t = f.tagAnyStrUntil([BidSpotRate.int, OfferSpotRate.int], 295, v)
#       if 0 == t:
#         break
#       echo t, ": ", v
#   let t = f.tagAnyStr([CheckSum.int], v)
#   echo t, ": ", v
