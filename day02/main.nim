import strformat, strutils, unittest

type
  Pos = ref object 
    x, y : int

  AimPos = ref object
    x, y, aim : int

func move(pos:Pos , dir: string, units: int): void =
  if dir == "forward":
    pos.x += units
  elif dir == "down":
    pos.y += units
  elif dir == "up":
    pos.y -= units

func move(pos:AimPos , dir: string, units: int): void =
  if dir == "down":
    pos.aim += units
  elif dir == "up":
    pos.aim -= units
  elif dir == "forward":
    pos.x += units
    pos.y += pos.aim * units

when is_main_module:
  let 
    file = readFile("input.txt").strip().splitLines()
  
  var movements: seq[tuple[dir: string, units: int]]

  for line in file:
    var 
      info = line.split(' ')
      dir = info[0]
      units = parseInt(info[1])
    
    movements.add((dir, units))

  block part1:
    var pos = Pos(x: 0, y: 0)

    for x in movements:
      move(pos, x.dir, x.units)
 
    echo fmt"pt1 ending pos: {pos.x},{pos.y}, multiplied: {pos.x * pos.y}"

  block part2:
    var pos = AimPos(x: 0, y: 0, aim: 0)

    for x in movements:
      move(pos, x.dir, x.units)

    echo fmt"pt2 ending pos: {pos.x},{pos.y}, multiplied: {pos.x * pos.y}"


suite "Sample Input":
  setup:
    const input = @[
      ("forward", 5),
      ("down", 5),
      ("forward", 8),
      ("up", 3),
      ("down", 8),
      ("forward", 2),
    ]
  
  test "part1":
    var pos = Pos(x: 0, y: 0)

    for x in input:
      pos.move(x[0], x[1])

    assert pos.x == 15
    assert pos.y == 10
    assert pos.x * pos.y == 150
  
  test "part2":
    var pos = AimPos(x: 0, y: 0, aim: 0)

    for x in input:
      pos.move(x[0], x[1])

    assert pos.x == 15
    assert pos.y == 60
    assert pos.x * pos.y == 900
