import strformat, strutils, sequtils, unittest, math

func countDescending(sequence: seq[int]): int =
  var
    descendingCount = 0
    prevItem = sequence[0]

  for item in sequence[1 ..< sequence.len()]:
    if prevItem < item:
      descendingCount += 1
    prevItem = item

  return descendingCount

func getWindowSums(sequence: seq[int], size: Natural): seq[int] =
  let fin = sequence.len() - size
  var res: seq[int]

  for x in countup(0, fin):
    let windowSum = sum(sequence[x ..< x+size])
    res.add(windowSum)

  return res

when is_main_module:
  let 
    file = readFile("input.txt").strip().splitLines()
    depths = file.map(parseInt)

  block part1:
    let descendingCount = countDescending(depths)
      
    echo fmt"""Number of increasing depth measurements: {descendingCount}"""

  block part2:
    var
      windows = getWindowSums(depths, 3)
      descendingCount = countDescending(windows)
      
    echo fmt"""Number of increasing depth measurements: {descendingCount}"""

suite "Sample Input":
  setup:
    const input = @[199,200,208,210,200,207,240,269,260,263]
  
  test "part1":
    assert countDescending(input) == 7
  
  test "part2":
    let windowSums = getWindowSums(input, 3)
    assert windowSums == @[607,618,618,617,647,716,769,792]
    assert countDescending(windowSums) == 5
