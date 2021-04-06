from parseutils import parseFloat

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

proc getAnyTag[N: static(int), T](fs: var StreamFix, tag: array[N, int], val: var T): int =
  while fs.pos < fs.len:
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
        return
      elif T is char:
        let start = fs.pos
        while fs.msg[fs.pos] != DELIMITER:
          inc fs.pos
        val = fs.msg[start]
        return
      elif T is int:
        while fs.msg[fs.pos] != DELIMITER:
          val = val * 10 + fs.msg[fs.pos].int - '0'.int
          inc fs.pos
        return
      elif T is uint:
        while fs.msg[fs.pos] != DELIMITER:
          val = val * 10 + fs.msg[fs.pos].uint - '0'.uint
          inc fs.pos
        return
      elif T is float:
        discard parseFloat(fs.msg, val, fs.pos)
        return
      else:
        {.error: "getTag does not support the generic type".}
    else:
      result = 0
      while fs.msg[fs.pos] != DELIMITER:
        inc fs.pos
      inc fs.pos

template mkTag(name: untyped, t: untyped) =
  proc `tag name`*(fs: var StreamFix, tag: int, val: var t): bool = 0 < getAnyTag[1, t](fs, [tag], val)
  proc `tagAny name`*[N: static int](fs: var StreamFix, tag: array[N, int], val: var t): int = getAnyTag[N, t](fs, tag, val)

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
