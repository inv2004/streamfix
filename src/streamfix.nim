from parseutils import parseFloat
import intsets

include streamfix/fields44
include streamfix/groups

type
  StreamFix* = object
    msg: string
    pos: int
    len: int

  StreamFixRef* = ref StreamFix

  Group*[grp: static[GroupSet]] = object
    sf: StreamFixRef
    len*: int

const DELIMITER = '\x01'

proc initFix*(msg: string): StreamFixRef =
  new(result)
  result.msg = msg
  result.pos = 0
  result.len = result.msg.len

proc getAnyTag*[N: static(int), T](fs: StreamFixRef, tag: array[N, int], val: var T): int =
  var pos = fs.pos
  while pos < fs.len:
    while fs.msg[pos] != '=':
      result = result * 10 + fs.msg[pos].int - '0'.int
      inc pos
    inc pos
    if result in tag:
      fs.pos = pos
      when T is string:
        while fs.msg[fs.pos] != DELIMITER:
          inc fs.pos
        val = fs.msg[pos..<fs.pos]
      elif T is char:
        while fs.msg[fs.pos] != DELIMITER:
          inc fs.pos
        val = fs.msg[pos]
      elif T is int:
        val = 0
        while fs.msg[fs.pos] != DELIMITER:
          val = val * 10 + fs.msg[fs.pos].int - '0'.int
          inc fs.pos
      elif T is uint:
        val = 0
        while fs.msg[fs.pos] != DELIMITER:
          val = val * 10 + fs.msg[fs.pos].uint - '0'.uint
          inc fs.pos
      elif T is float:
        fs.pos += parseFloat(fs.msg, val, fs.pos)
      else:
        {.error: "getTag does not support the generic type".}
      inc fs.pos
      return
    else:
      result = 0
      while fs.msg[pos] != DELIMITER:
        inc pos
      inc pos

proc getTag*[T](fs: StreamFixRef, tag: int, val: var T): int =
  var pos = fs.pos
  while pos < fs.len:
    while fs.msg[pos] != '=':
      result = result * 10 + fs.msg[pos].int - '0'.int
      inc pos
    inc pos
    if result == tag:
      fs.pos = pos
      when T is string:
        while fs.msg[fs.pos] != DELIMITER:
          inc fs.pos
        val = fs.msg[pos..<fs.pos]
      elif T is char:
        while fs.msg[fs.pos] != DELIMITER:
          inc fs.pos
        val = fs.msg[pos]
      elif T is int:
        val = 0
        while fs.msg[fs.pos] != DELIMITER:
          val = val * 10 + fs.msg[fs.pos].int - '0'.int
          inc fs.pos
      elif T is uint:
        val = 0
        while fs.msg[fs.pos] != DELIMITER:
          val = val * 10 + fs.msg[fs.pos].uint - '0'.uint
          inc fs.pos
      elif T is float:
        fs.pos += parseFloat(fs.msg, val, fs.pos)
      else:
        {.error: "getTag does not support the generic type".}
      inc fs.pos
      return
    else:
      result = 0
      while fs.msg[pos] != DELIMITER:
        inc pos
      inc pos

proc getAnyTagUntil*[N: static(int), T](fs: StreamFixRef, tag: array[N, int], until: int, val: var T): int =
  var pos = fs.pos
  while pos < fs.len:
    while fs.msg[pos] != '=':
      result = result * 10 + fs.msg[pos].int - '0'.int
      inc pos
    inc pos
    if result in tag:
      fs.pos = pos
      when T is string:
        while fs.msg[fs.pos] != DELIMITER:
          inc fs.pos
        val = fs.msg[pos..<fs.pos]
      elif T is char:
        while fs.msg[fs.pos] != DELIMITER:
          inc fs.pos
        val = fs.msg[pos]
      elif T is int:
        val = 0
        while fs.msg[fs.pos] != DELIMITER:
          val = val * 10 + fs.msg[fs.pos].int - '0'.int
          inc fs.pos
      elif T is uint:
        val = 0
        while fs.msg[fs.pos] != DELIMITER:
          val = val * 10 + fs.msg[fs.pos].uint - '0'.uint
          inc fs.pos
      elif T is float:
        fs.pos += parseFloat(fs.msg, val, fs.pos)
      else:
        {.error: "getTag does not support the generic type".}
      inc fs.pos
      return
    elif result == until:
      result = 0
      return      
    else:
      result = 0
      while fs.msg[pos] != DELIMITER:
        inc pos
      inc pos

proc getGroup*[N,F](fs: StreamFixRef, gd: static GroupDesc[N, F]): Group[F] =
  discard getAnyTag[1, int](fs, [gd.num], result.len)
  result.sf = fs
  return

proc getAnyTagG*[N: static(int), T](g: Group, tag: array[N, int], val: var T): int =
  let fs = g.sf
  while fs.pos < fs.len:
    let prev = fs.pos
    while fs.msg[fs.pos] != '=':
      result = result * 10 + fs.msg[fs.pos].int - '0'.int
      inc fs.pos
    inc fs.pos
    if tag.contains(result):
      when T is string:
        let start = fs.pos
        while fs.msg[fs.pos] != DELIMITER:
          inc fs.pos
        val = fs.msg[start..<fs.pos]
      elif T is char:
        let start = fs.pos
        while fs.msg[fs.pos] != DELIMITER:
          inc fs.pos
        val = fs.msg[start]
      elif T is int:
        while fs.msg[fs.pos] != DELIMITER:
          val = val * 10 + fs.msg[fs.pos].int - '0'.int
          inc fs.pos
      elif T is uint:
        while fs.msg[fs.pos] != DELIMITER:
          val = val * 10 + fs.msg[fs.pos].uint - '0'.uint
          inc fs.pos
      elif T is float:
        discard parseFloat(fs.msg, val, fs.pos)
      else:
        {.error: "getTag does not support the generic type".}
      inc fs.pos
      return
    elif result in g.grp:
      result = 0
      while fs.msg[fs.pos] != DELIMITER:
        inc fs.pos
      inc fs.pos
    else:
      result = 0
      fs.pos = prev
      return

template mkTag(name: untyped, t: untyped) =
  proc `tag name`*(fs: StreamFixRef, tag: int, val: var t): bool = 0 < getAnyTag[1, t](fs, [tag], val)
  proc `tagAny name`*[N: static int](fs: StreamFixRef, tag: array[N, int], val: var t): int = getAnyTag[N, t](fs, tag, val)
  proc `tagAny name Until`*[N: static int](fs: StreamFixRef, tag: array[N, int], until: int, val: var t): int = getAnyTagUntil[N, t](fs, tag, until, val)
  proc `get name`*(fs: StreamFixRef, tag: int): t = discard getAnyTag[1, t](fs, [tag], result)

mkTag(Str, string)
mkTag(Char, char)
mkTag(Int, int)
mkTag(UInt, uint)
mkTag(Float, float)

proc main() =
  let s = readLines("tests/test2.fix", 5)
  var f = initFix(s[4])
  doAssert 'i' == f.getChar(MsgType.int)
  var v: string
  let gr1 = f.getGroup(GrpNoQuoteSets)
  doAssert 5 == gr1.len
  while true:
    let t = gr1.getAnyTagG([QuoteSetID.int], v)
    if 0 == t:
      break
    echo t, ": ", v
    let gr2 = f.getGroup(GrpNoQuoteEntries)
    while true:
      let t = gr2.getAnyTagG([BidSpotRate.int, OfferSpotRate.int], v)
      if 0 == t:
        break
      echo t, ": ", v
  let t = f.tagAnyStr([CheckSum.int], v)
  echo t, ": ", v

when isMainModule:
  main()
