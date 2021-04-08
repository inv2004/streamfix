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
  let s4 = readLines("tests/test2.fix", 5)[4]

  proc fix1R(): int =
    var f = initFix(s4)
    var res: string
    for i in 1..20:
      if f.tagStr(190, res):
        result += res.len

  proc fix1A(): int =
    var f = initFix(s4)
    doAssert 'i' == f.getChar(MsgType.int)
    var v: string
    let gr1 = f.getGroup(GrpNoQuoteSets)
    doAssert 5 == gr1.len
    while true:
      let t = gr1.getAnyTagG([QuoteSetID.int], v)
      if 0 == t:
        break
      let gr2 = f.getGroup(GrpNoQuoteEntries)
      while true:
        let t = gr2.getAnyTagG([BidSpotRate.int, OfferSpotRate.int], v)
        if 0 == t:
          break
    let t = f.tagAnyStr([CheckSum.int], v)

  proc fix2A(): int =
    var f = initFix(s4)
    doAssert 'i' == f.getChar(MsgType.int)
    var v: string
    while true:
      if not f.tagStr(QuoteSetID.int, v):
        break
      discard f.tagAnyStr([NoQuoteEntries.int], v)
      while true:
        let t = f.getAnyTagGrp(GrpNoQuoteEntries.fields, [BidSpotRate.int, OfferSpotRate.int], v)
        if 0 == t:
          break
    let t = f.tagAnyStr([CheckSum.int], v)

  proc fix3A(): int =
    var f = initFix(s4)
    doAssert 'i' == f.getChar(MsgType.int)
    var v: string
    while true:
      if not f.tagStr(QuoteSetID.int, v):
        break
      discard f.tagAnyStr([NoQuoteEntries.int], v)
      while true:
        let t = f.getAnyTagGrp(GrpNoQuoteEntries.fields, [BidSpotRate.int, OfferSpotRate.int], v)
        if 0 == t:
          break
    let t = f.tagAnyStr([CheckSum.int], v)

  proc fix4A(): int =
    var f = initFix(s4)
    doAssert 'i' == f.getChar(MsgType.int)
    var v: string
    while true:
      if not f.tagStr(QuoteSetID.int, v):
        break
      discard f.tagAnyStr([NoQuoteEntries.int], v)
      while true:
        let t = f.tagAnyStrUntil([BidSpotRate.int, OfferSpotRate.int], 295, v)
        if 0 == t:
          break
    let t = f.tagAnyStr([CheckSum.int], v)

  # proc benchFix1R() {.measure.} =
  #   blackBox fix1R()

  proc benchFix1A() {.measure.} =
    blackBox fix1A()

  proc benchFix2A() {.measure.} =
    blackBox fix2A()

  proc benchFix3A() {.measure.} =
    blackBox fix3A()

  proc benchFix4A() {.measure.} =
    blackBox fix4A()

  proc fix2(): int =
    var f = initFix2(s4)
    for i in 1..20:
      result += f.tag2("190=").len

  proc fix3(): int =
    var f = initFix3(s4)
    for i in 1..20:
      result += f.tag3("190=").len
    c_free(f.c)

  # proc benchFix2() {.measure.} =
  #   blackBox fix2()

  # proc benchFix3() {.measure.} =
  #   blackBox fix3()
