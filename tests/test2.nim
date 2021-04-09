import unittest

import streamfix

let fix = readLines("tests/test2.fix",5)

test "fix42 minimal":
  var s: string
  var i: int
  var c: char
  var f = initFix(fix[0])
  check f.tagStr(8, s)
  check "FIX.4.2" == s
  check f.tagInt(9, i)
  check 101 == i
  check f.tagChar(35, c)
  check 'e' == c
  check f.tagStr(49, s)
  check "TTTTTTT6" == s
  check f.tagStr(56, s)
  check "872" == s
  check f.tagStr(5555, s)
  check "6236.83333333" == s
  check f.tagInt(34, i)
  check 99 == i
  check f.tagStr(52, s)
  check "20140709-14:43:12.934" == s
  check f.tagChar(7777, c)
  check 'Y' == c
  check f.tagStr(57, s)
  check "ARCA" == s
  check f.tagInt(108, i)
  check 60 == i
  check f.tagInt(98, i)
  check 0 == i
  check f.tagStr(10, s)
  check "114" == s

test "fix42 group":
  var s: string
  var i: int
  var c: char
  var f = initFix(fix[1])
  check f.tagStr(8, s)
  check "FIX.4.2" == s
  check f.tagInt(9, i)
  check 157 == i
  check f.tagChar(35, c)
  check 'a' == c
  check f.tagStr(49, s)
  check "TTTTTTT6" == s
  check f.tagStr(56, s)
  check "44611" == s
  check f.tagStr(5555, s)
  check "11855.33" == s
  check f.tagInt(34, i)
  check 58 == i
  check f.tagStr(52, s)
  check "20140709-15:01:26.209" == s

  let gr1 = f.getGroup(GrpNoRelatedSym)
  i = 0
  while true:
    if 0 == gr1.getAnyTagG([55], s):
      break
    if i == 0:
      check "AAPL" == s
      discard gr1.getAnyTagG([64], s)
      check "65912" == s
      discard gr1.getAnyTagG([107], s)
      check "blah1" == s
    else:
      check "IBM" == s
      discard gr1.getAnyTagG([64], s)
      check "56132" == s
      discard gr1.getAnyTagG([107], s)
      check "blah2" == s
    inc i

  check f.tagChar(777, c)
  check 'Y' == c
  check f.tagStr(57, s)
  check "ARCA" == s
  check f.tagInt(108, i)
  check 60 == i
  check f.tagInt(98, i)
  check 0 == i
  check f.tagStr(10, s)
  check "114" == s

test "fix42 group+subgroup ":
  var s: string
  var i: int
  var c: char
  var f = initFix(fix[2])
  check f.tagStr(8, s)
  check "FIX.4.2" == s
  check f.tagInt(9, i)
  check 272 == i
  check f.tagChar(35, c)
  check 'a' == c
  check f.tagStr(49, s)
  check "TTTTTTT6" == s
  check f.tagStr(56, s)
  check "63016" == s
  check f.tagStr(5555, s)
  check "4592.00" == s
  check f.tagInt(34, i)
  check 64 == i
  check f.tagStr(52, s)
  check "20140709-19:38:42.653" == s

  let gr1 = f.getGroup(GrpNoRelatedSym)
  i = 0
  while true:
    if 0 == gr1.getAnyTagG([55], s):
      break
    if i == 0:
      check "AAPL" == s
      discard gr1.getAnyTagG([64], s)
      check "61245" == s
      discard gr1.getAnyTagG([107], s)
      check "blah1" == s
      let gr2 = f.getGroup(GrpNoNested3PartyIDs)
      var j = 0
      while true:
        if 0 == gr2.getAnyTagG([949], s):
          break
        if j == 0:
          check "61245" == s
          discard gr2.getAnyTagG([950], s)
          check "21785" == s
        else:
          check "foo421" == s
          discard gr2.getAnyTagG([950], s)
          check "foo422" == s
        inc j
    else:
      check "IBM" == s
      discard gr1.getAnyTagG([64], s)
      check "21785" == s
      discard gr1.getAnyTagG([107], s)
      check "blah2" == s
      let gr2 = f.getGroup(GrpNoNested3PartyIDs)
      var j = 0
      while true:
        if 0 == gr2.getAnyTagG([949], s):
          break
        if j == 0:
          check "15732" == s
          discard gr2.getAnyTagG([950], s)
          check "39740" == s
        else:
          check "foo421" == s
          discard gr2.getAnyTagG([950], s)
          check "foo422" == s
        inc j
    inc i

  check f.tagChar(777, c)
  check 'Y' == c
  check f.tagStr(57, s)
  check "ARCA" == s
  check f.tagInt(108, i)
  check 60 == i
  check f.tagInt(98, i)
  check 0 == i
  check f.tagStr(10, s)
  check "114" == s

test "fix44 pxm 314b":
  var f = initFix(fix[3])
  check 'i' == f.getChar(MsgType.int)
  var bidLen = 0
  var offerLen = 0
  var v: string
  let gr1 = f.getGroup(GrpNoQuoteSets)
  check 1 == gr1.len
  while true:
    let t = gr1.getAnyTagG([QuoteSetID.int], v)
    if 0 == t:
      break
    let gr2 = f.getGroup(GrpNoQuoteEntries)
    while true:
      let t = gr2.getAnyTagG([BidSpotRate.int, OfferSpotRate.int], v)
      if 0 == t:
        break
      elif 188 == t:
        bidLen += v.len
      else:
        offerLen += v.len
  check 35 == bidLen
  check 34 == offerLen

test "fix44 pxm 1k":
  var f = initFix(fix[4])
  check 'i' == f.getChar(MsgType.int)
  var bidLen = 0
  var offerLen = 0
  var v: string
  let gr1 = f.getGroup(GrpNoQuoteSets)
  check 5 == gr1.len
  while true:
    let t = gr1.getAnyTagG([QuoteSetID.int], v)
    if 0 == t:
      break
    let gr2 = f.getGroup(GrpNoQuoteEntries)
    while true:
      let t = gr2.getAnyTagG([BidSpotRate.int, OfferSpotRate.int], v)
      if 0 == t:
        break
      elif 188 == t:
        bidLen += v.len
      else:
        offerLen += v.len
  check 124 == bidLen
  check 130 == offerLen
