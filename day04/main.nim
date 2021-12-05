import strformat, strutils, sequtils, unittest, tables

type Position = ref object 
  r: int
  c: int
  marked: bool

func newBoard(): seq[seq[int]] =
  for i in 0 ..< 5:
    result.add(@[])
    for j in 0 ..< 5:
      result[i].add(0)

proc hasWon(board: seq[seq[int]], pos: Position, positions: Table[int, Position]): bool =
  # assume the board is a winner unless proven otherwise
  var byRows, byCols = true
  for i in 0 ..< 5:
    let num = board[i][pos.c]
    if not positions[num].marked:
      byCols = false
      break

  for i in 0 ..< 5:
    let num = board[pos.r][i]
    if not positions[num].marked:
      byRows = false
      break

  return byRows or byCols

func sumUnmarked(board: seq[seq[int]], positions: Table[int, Position]): int =
  for row in board:
    for num in row:
      if not positions[num].marked:
        result += num  

when is_main_module:
  let 
    file = readFile("input.txt").strip().splitLines()
    calls = file[0].split(',').map(parseInt)
  var
    boards: seq[seq[seq[int]]]
    # stores the row and column where each number in a board resides
    positions: seq[Table[int, Position]]
    # stores boards that are in the winning state
    winners: Table[int, bool]
    board = -1
    row = -1

  for line in file[1 ..< len(file)]:
    # a new board has started
    if len(line) == 0:
      row = 0
      inc board
      boards.add(newBoard())
      positions.add(initTable[int, Position]())
    else:
      for col, num in line.splitWhitespace().map(parseInt):
        boards[board][row][col] = num
        positions[board][num] = Position(r: row, c: col, marked: false)
      inc row

  for call in calls:
    for i, board in boards:
      let position = positions[i]

      if not position.contains(call):
        continue

      position[call].marked = true

      if winners.contains(i) or not board.hasWon(position[call], position):
        continue

      winners[i] = true
      let sumUnmarked = board.sumUnmarked(position)

      if len(winners) == 1:
        echo fmt"pt1 sum unmarked: {sumUnmarked}, call: {call} final score: {sumUnmarked * call}"
      elif len(winners) == len(boards):
        echo fmt"pt2 sum unmarked: {sumUnmarked}, call: {call} final score: {sumUnmarked * call}"
