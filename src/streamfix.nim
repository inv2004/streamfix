from parseutils import parseFloat

type
  StreamFix* = object
    msg: string
    pos: int
    len: int

proc initFix*(msg: string): StreamFix =
  result.msg = msg
  result.pos = 0
  result.len = result.msg.len

proc getTag[T](fs: var StreamFix, tag: int): T =
  var t: int
  while fs.pos < fs.len:
    while fs.msg[fs.pos] != '=':
      t = t * 10 + fs.msg[fs.pos].int - '0'.int
      inc fs.pos
    inc fs.pos
    if tag == t:
      when T is string:
        t = fs.pos
        while fs.msg[fs.pos] != '\x01':
          inc fs.pos
        return fs.msg[t..<fs.pos]
      elif T is char:
        t = fs.pos
        while fs.msg[fs.pos] != '\x01':
          inc fs.pos
        return fs.msg[t]
      elif T is int:
        while fs.msg[fs.pos] != '\x01':
          result = result * 10 + fs.msg[fs.pos].int - '0'.int
          inc fs.pos
        return
      elif T is uint:
        while fs.msg[fs.pos] != '\x01':
          result = result * 10 + fs.msg[fs.pos].uint - '0'.uint
          inc fs.pos
        return
      elif T is uint:
        while fs.msg[fs.pos] != '\x01':
          result = result * 10 + fs.msg[fs.pos].uint - '0'.uint
          inc fs.pos
        return
      elif T is float:
        discard parseFloat(fs.msg, result, fs.pos)
        return
      else:
        {.error: "getTag does not support the generic type".}
    else:
      t = 0
      while fs.msg[fs.pos] != '\x01':
        inc fs.pos
      inc fs.pos

proc getAnyTag[N: static(int), T](fs: var StreamFix, tag: array[N, int]): T =
  var t: int
  while fs.pos < fs.len:
    while fs.msg[fs.pos] != '=':
      t = t * 10 + fs.msg[fs.pos].int - '0'.int
      inc fs.pos
    inc fs.pos
    if t in tag:
      when T is string:
        t = fs.pos
        while fs.msg[fs.pos] != '\x01':
          inc fs.pos
        return fs.msg[t..<fs.pos]
      elif T is char:
        t = fs.pos
        while fs.msg[fs.pos] != '\x01':
          inc fs.pos
        return fs.msg[tt]
      elif T is int:
        while fs.msg[fs.pos] != '\x01':
          result = result * 10 + fs.msg[fs.pos].int - '0'.int
          inc fs.pos
        return
      elif T is uint:
        while fs.msg[fs.pos] != '\x01':
          result = result * 10 + fs.msg[fs.pos].uint - '0'.uint
          inc fs.pos
        return
      elif T is float:
        discard parseFloat(fs.msg, result, fs.pos)
        return
      else:
        {.error: "getTag does not support the generic type".}
    else:
      t = 0
      while fs.msg[fs.pos] != '\x01':
        inc fs.pos
      inc fs.pos

proc tagStr*(fs: var StreamFix, tag: int): string = getTag[string](fs, tag)
proc tagChar*(fs: var StreamFix, tag: int): char = getTag[char](fs, tag)
proc tagInt*(fs: var StreamFix, tag: int): int = getTag[int](fs, tag)
proc tagUInt*(fs: var StreamFix, tag: int): uint = getTag[uint](fs, tag)
proc tagFloat*(fs: var StreamFix, tag: int): float = getTag[float](fs, tag)

proc tagAnyStr*[N: static(int)](fs: var StreamFix, tags: array[N, int]): string = getAnyTag[N, string](fs, tags)

proc main() =
  let s = readLines("tests/test1.fix", 5)
  var f1 = initFix(s[4])
  for i in 1..20:
    echo f1.tagStr(190)

when isMainModule:
  main()
