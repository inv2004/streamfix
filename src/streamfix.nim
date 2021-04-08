from parseutils import parseFloat

include fields44

type
  StreamFix* = object
    msg: string
    pos: int
    len: int

const DELIMITER = '\x01'

proc initFix*(msg: string): StreamFix =
  result.msg = msg
  result.pos = 0
  result.len = result.msg.len

const grpI* = [302, 295, 299, 106, 134, 135, 188, 190]
const grpII* = [299, 106, 134, 135, 188, 190]

proc getAnyTagGrp*[N: static(int), T](fs: var StreamFix, grp:array[8, int], tag: array[N, int], val: var T): int =
  while fs.pos < fs.len:
    let prev = fs.pos
    while fs.msg[fs.pos] != '=':
      result = result * 10 + fs.msg[fs.pos].int - '0'.int
      inc fs.pos
    inc fs.pos
    if result in tag:
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
    elif result in grp:
      result = 0
      while fs.msg[fs.pos] != DELIMITER:
        inc fs.pos
      inc fs.pos
    else:
      result = 0
      fs.pos = prev
      return

proc getAnyTagGrp*[N: static(int), T](fs: var StreamFix, grp:array[6, int], tag: array[N, int], val: var T): int =
  while fs.pos < fs.len:
    let prev = fs.pos
    while fs.msg[fs.pos] != '=':
      result = result * 10 + fs.msg[fs.pos].int - '0'.int
      inc fs.pos
    inc fs.pos
    if result in tag:
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
    elif result in grp:
      result = 0
      while fs.msg[fs.pos] != DELIMITER:
        inc fs.pos
      inc fs.pos
    else:
      result = 0
      fs.pos = prev
      return

proc getAnyTag*[N: static(int), T](fs: var StreamFix, tag: array[N, int], val: var T): int =
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
        while fs.msg[fs.pos] != DELIMITER:
          val = val * 10 + fs.msg[fs.pos].int - '0'.int
          inc fs.pos
      elif T is uint:
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

proc getAnyTagUntil*[N: static(int), T](fs: var StreamFix, tag: array[N, int], until: int, val: var T): int =
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
        while fs.msg[fs.pos] != DELIMITER:
          val = val * 10 + fs.msg[fs.pos].int - '0'.int
          inc fs.pos
      elif T is uint:
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

template mkTag(name: untyped, t: untyped) =
  proc `tag name`*(fs: var StreamFix, tag: int, val: var t): bool = 0 < getAnyTag[1, t](fs, [tag], val)
  proc `tagAny name`*[N: static int](fs: var StreamFix, tag: array[N, int], val: var t): int = getAnyTag[N, t](fs, tag, val)
  proc `tagAny name Until`*[N: static int](fs: var StreamFix, tag: array[N, int], until: int, val: var t): int = getAnyTagUntil[N, t](fs, tag, until, val)
  proc `get name`*(fs: var StreamFix, tag: int): t = discard getAnyTag[1, t](fs, [tag], result)

mkTag(Str, string)
mkTag(Char, char)
mkTag(Int, int)
mkTag(UInt, uint)
mkTag(Float, float)

proc main() =
  let s = readLines("tests/test1.fix", 5)
  var f1 = initFix(s[4])
  var res: string
  for i in 1..20:
    discard f1.tagStr(190, res)

when isMainModule:
  main()
