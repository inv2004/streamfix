{.compile: "fix.c".}

import streamfix

import criterion

type
  StreamFix2 = object
    pos: pointer
    msg: string
    last: pointer

proc initFix2(msg: string): StreamFix2 =
  result.msg = msg
  result.pos = result.msg[0].unsafeAddr
  result.last = result.msg[result.msg.len-1].unsafeAddr

proc c_memcmp*(a, b: pointer, size: csize_t): cint {.
              importc: "memcmp", header: "<string.h>", noSideEffect.}

proc c_memchr(cstr: pointer, c: char, n: csize_t): pointer {.
              importc: "memchr", header: "<string.h>".}

proc tag2(f: var StreamFix2, tag: string): string =
  let tLen = cast[csize_t](tag.len)
  let tAddr = tag[0].unsafeAddr
  while f.pos < f.last:
    if 0 == c_memcmp(f.pos, tAddr, tLen):
      f.pos = cast[pointer](cast[uint](f.pos) + tLen)
      let nextAddr = c_memchr(f.pos, '\x01', cast[csize_t](1000))
      let len = cast[ByteAddress](nextAddr) - cast[ByteAddress](f.pos)
      result = newString(len)
      copyMem(result[0].addr, f.pos, len)
      return
    else:
      f.pos = c_memchr(f.pos, '\x01', cast[csize_t](1000))
      f.pos = cast[pointer](cast[uint](f.pos) + 1u)

type
  CFS = ptr object
  FS = object
    c: CFS

proc c_init(msg: cstring): CFS {.importc: "finit".}
proc c_tag(fs: CFS, tag: cstring): cstring {.importc: "ftag3".}
proc c_free(fs: CFS) {.importc: "ffree".}

proc initFix3(msg: string): FS =
  FS(c: c_init(msg))

proc tag3(fs: FS, tag: cstring): cstring =
  c_tag(fs.c, tag)

var cfg = newDefaultConfig()

benchmark cfg:
  let s0 = readLines("tests/test2.fix", 5)[0]
  let s1 = readLines("tests/test2.fix", 5)[1]
  let s2 = readLines("tests/test2.fix", 5)[2]
  let s3 = readLines("tests/test2.fix", 5)[3]
  let s4 = readLines("tests/test2.fix", 5)[4]

  proc fix1(): int =
    var s: string
    var i: int
    var c: char
    var f = initFix(s0)
    discard f.tagStr(8, s)
    doAssert "FIX.4.2" == s
    discard f.tagInt(9, i)
    doAssert 101 == i
    discard f.tagChar(35, c)
    doAssert 'e' == c
    discard f.tagStr(49, s)
    doAssert "TTTTTTT6" == s
    discard f.tagStr(56, s)
    doAssert "872" == s
    discard f.tagStr(5555, s)
    doAssert "6236.83333333" == s
    discard f.tagInt(34, i)
    doAssert 99 == i
    discard f.tagStr(52, s)
    doAssert "20140709-14:43:12.934" == s
    discard f.tagChar(7777, c)
    doAssert 'Y' == c
    discard f.tagStr(57, s)
    doAssert "ARCA" == s
    discard f.tagInt(108, i)
    doAssert 60 == i
    discard f.tagInt(98, i)
    doAssert 0 == i
    discard f.tagStr(10, s)
    doAssert "114" == s

  proc benchFix1() {.measure.} =
    blackBox fix1()

  proc fix42grp(): int =
    var s: string
    var i: int
    var c: char
    var f = initFix(s1)
    discard f.tagStr(8, s)
    doAssert "FIX.4.2" == s
    discard f.tagInt(9, i)
    doAssert 157 == i
    discard f.tagChar(35, c)
    doAssert 'a' == c
    discard f.tagStr(49, s)
    doAssert "TTTTTTT6" == s
    discard f.tagStr(56, s)
    doAssert "44611" == s
    discard f.tagStr(5555, s)
    doAssert "11855.33" == s
    discard f.tagInt(34, i)
    doAssert 58 == i
    discard f.tagStr(52, s)
    doAssert "20140709-15:01:26.209" == s

    let gr1 = f.getGroup(GrpNoRelatedSym)
    while true:
      if 0 == gr1.getAnyTagG([55], s):
        break
      if i == 0:
        discard gr1.getAnyTagG([64], s)
        discard gr1.getAnyTagG([107], s)
      else:
        discard gr1.getAnyTagG([64], s)
        discard gr1.getAnyTagG([107], s)

    discard f.tagChar(777, c)
    doAssert 'Y' == c
    discard f.tagStr(57, s)
    doAssert "ARCA" == s
    discard f.tagInt(108, i)
    doAssert 60 == i
    discard f.tagInt(98, i)
    doAssert 0 == i
    discard f.tagStr(10, s)
    doAssert "114" == s


  proc benchFix42Grp() {.measure.} =
    blackBox fix42grp()

  proc fix42grpsub(): int =
    var s: string
    var i: int
    var c: char
    var f = initFix(s2)
    discard f.tagStr(8, s)
    doAssert "FIX.4.2" == s
    discard f.tagInt(9, i)
    doAssert 272 == i
    discard f.tagChar(35, c)
    doAssert 'a' == c
    discard f.tagStr(49, s)
    doAssert "TTTTTTT6" == s
    discard f.tagStr(56, s)
    doAssert "63016" == s
    discard f.tagStr(5555, s)
    doAssert "4592.00" == s
    discard f.tagInt(34, i)
    doAssert 64 == i
    discard f.tagStr(52, s)
    doAssert "20140709-19:38:42.653" == s

    let gr1 = f.getGroup(GrpNoRelatedSym)
    i = 0
    while true:
      if 0 == gr1.getAnyTagG([55], s):
        break
      discard gr1.getAnyTagG([64], s)
      discard gr1.getAnyTagG([107], s)
      let gr2 = f.getGroup(GrpNoNested3PartyIDs)
      while true:
        if 0 == gr2.getAnyTagG([949], s):
          break
        discard gr2.getAnyTagG([950], s)

    discard f.tagChar(777, c)
    doAssert 'Y' == c
    discard f.tagStr(57, s)
    doAssert "ARCA" == s
    discard f.tagInt(108, i)
    doAssert 60 == i
    discard f.tagInt(98, i)
    doAssert 0 == i
    discard f.tagStr(10, s)
    doAssert "114" == s

  proc benchFix42GrpSub() {.measure.} =
    blackBox fix42grpsub()

  proc fix42pxm314(): int =
    var f = initFix(s3)
    doAssert 'i' == f.getChar(MsgType.int)
    var v: string
    let gr1 = f.getGroup(GrpNoQuoteSets)
    while true:
      let t = gr1.getAnyTagG([QuoteSetID.int], v)
      if 0 == t:
        break
      let gr2 = f.getGroup(GrpNoQuoteEntries)
      while true:
        let t = gr2.getAnyTagG([QuoteEntryID.int], v)
        if 0 == t:
          break
        discard gr2.getAnyTagG([Issuer.int], v)
        discard gr2.getAnyTagG([BidSize.int, OfferSize.int], v)
        discard gr2.getAnyTagG([BidSpotRate.int, OfferSpotRate.int], v)

  proc benchFix42Pxm314() {.measure.} =
    blackBox fix42pxm314()

  proc fix42pxm1k(): int =
    var f = initFix(s4)
    doAssert 'i' == f.getChar(MsgType.int)
    var v: string
    let gr1 = f.getGroup(GrpNoQuoteSets)
    while true:
      let t = gr1.getAnyTagG([QuoteSetID.int], v)
      if 0 == t:
        break
      let gr2 = f.getGroup(GrpNoQuoteEntries)
      while true:
        let t = gr2.getAnyTagG([QuoteEntryID.int], v)
        if 0 == t:
          break
        discard gr2.getAnyTagG([Issuer.int], v)
        discard gr2.getAnyTagG([BidSize.int, OfferSize.int], v)
        discard gr2.getAnyTagG([BidSpotRate.int, OfferSpotRate.int], v)

  proc benchFix42Pxm1k() {.measure.} =
    blackBox fix42pxm1k()

  # proc fix1R(): int =
  #   var f = initFix(s4)
  #   var res: string
  #   for i in 1..20:
  #     if f.tagStr(190, res):
  #       result += res.len


  # proc benchFix1A() {.measure.} =
  #   blackBox fix1A()

  # proc benchFix2A() {.measure.} =
  #   blackBox fix2A()


  # proc fix2(): int =
  #   var f = initFix2(s4)
  #   for i in 1..20:
  #     result += f.tag2("190=").len

  # proc fix3(): int =
  #   var f = initFix3(s4)
  #   for i in 1..20:
  #     result += f.tag3("190=").len
  #   c_free(f.c)

  # proc benchFix2() {.measure.} =
  #   blackBox fix2()

  # proc benchFix3() {.measure.} =
  #   blackBox fix3()
