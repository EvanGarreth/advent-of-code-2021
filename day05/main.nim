import strformat, strutils, sequtils, unittest, sugar, tables

type
  Point = tuple[x, y: int]
  Line = tuple[p1: Point, p2: Point]
  Diagram = CountTableRef[Point]

# can handle this better but I have things to do today
func toLine(pair: seq[string]): Line =
  var points: seq[Point]
  for p in pair:
    var
      x, y: int
      split = p.split(',').map(parseInt)
    x = split[0]
    y = split[1]
    points.add((x, y))

  result = (points[0], points[1])

proc draw(diagram: Diagram, line: Line): void =
  var
    (p1, p2) = line
    steep = abs(p1.x - p2.x) < abs(p1.y - p2.y)

  # transpose the line
  if steep:
    swap(p1.x, p1.y)
    swap(p2.x, p2.y)

  # ensure p1 is the leftmost of the two points
  if p1.x > p2.x:
    swap(p1, p2)

  let
    dx = p2.x - p1.x
    dy = p2.y - p1.y
  var
    # used to correct the y position of the points
    derror2 = abs(dy) * 2
    error2 = 0
    y = p1.y

  for x in p1.x .. p2.x:
    # remove the transpose before drawing if needed
    let point = if steep: (y, x) else: (x, y)
    diagram.inc(point)

    error2 += derror2
    if error2 > dx:
      if p2.y > p1.y:
        inc y
      else:
        dec y
      error2 -= dx * 2

func isDiagonal(line: Line): bool =
  return line.p1.x != line.p2.x and line.p1.y != line.p2.y

func is45DegreeDiagonal(line: Line): bool =
  let
    dx = line.p1.x - line.p2.x
    dy = line.p1.y - line.p2.y
    slope = dy / dx

  return slope == 1 or slope == -1

proc countOverlapping(candidates: seq[Line], op: proc (x: Line): bool): int =
  let lines = candidates.filter(op)
  # not displaying the "map" so just need to count the times a point is part of a line
  var diagram: Diagram = newCountTable[Point]()

  for line in lines:
    diagram.draw(line)

  for val in diagram.values:
    if val > 1:
      inc result

when is_main_module:
  let 
    file = readFile("input.txt").strip().splitLines()
    lines = file.map((x) => x.split(" -> ")).map(toLine)

  let
    count1 = countOverlapping(lines, (l) => not isDiagonal(l))
    count2 = countOverlapping(lines, (l) => not isDiagonal(l) or is45DegreeDiagonal(l))

  echo fmt"pt1 # points with overlaps: {count1}"
  echo fmt"pt2 # points with overlaps: {count2}"

suite "Tests":
  setup:
    const input: seq[Line] = @[
      ((0,9), (5,9)),
      ((8,0), (0,8)),
      ((9,4), (3,4)),
      ((2,2), (2,1)),
      ((7,0), (7,4)),
      ((6,4), (2,0)),
      ((0,9), (2,9)),
      ((3,4), (1,4)),
      ((0,0), (8,8)),
      ((5,5), (8,2))
    ]

  test "part1":
    let count = countOverlapping(input, (l) => not isDiagonal(l))

    assert count == 5

  test "part2":
    let count = countOverlapping(input, (l) => not isDiagonal(l) or is45DegreeDiagonal(l))

    assert count == 12
