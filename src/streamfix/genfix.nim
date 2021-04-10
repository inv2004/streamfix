import xmlparser, xmltree
import strtabs
import tables
import strutils
import sequtils
import os

proc uncapitalizeAscii(s: string): string =
  if s.len == 0: result = ""
  else: result = toLowerAscii(s[0]) & substr(s, 1)

proc genFields(xml: XmlNode) =
  echo """type
  Fields = enum"""

  for f in xml.child("fields"):
    echo "    ", f.attrs["name"], " = ", f.attrs["number"]

proc main() =
  if os.paramCount() == 1 and os.paramStr(1).endsWith(".xml"):
    let xml = loadXml(os.paramStr(1))
    let ra = xml.attrs
    var name = ra["type"].toLowerAscii().capitalizeAscii() & ra["major"] & ra["minor"]
    if ra["servicepack"] != "0":
      name.add ra["servicepack"].capitalizeAscii()
    genFields(xml)
  else:
    echo "Use: ./genfix [SPEC.xml]"

main()
