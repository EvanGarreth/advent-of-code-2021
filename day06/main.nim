import strformat, strutils, sequtils, math

when is_main_module:
  var
    file = readFile("input.txt").strip().splitLines()
    states = [0,0,0,0,0,0,0,0,0]
    startingStates = file[0].split(',').map(parseInt)
    current: int64 = 0

  for state in startingStates:
    inc states[state]

  # pt1 goes to 80 days. pt2 256
  while current < 256:
    var prev = 0
    for state in countdown(len(states)-1, 0):
      # fish in these states just move to a lower state
      if state > 0:
        let temp = states[state]
        states[state] = prev
        prev = temp
      # "spawn" new fish at state 8, add the older fish to what is in state 6 
      if state == 0:
        states[6] += states[0]
        states[8] = states[0]
        states[0] = prev
    inc current

    if current == 80:
      echo fmt"pt1 fish after 80 iterations: {sum(states)}"

  echo fmt"pt2 fish after 256 iterations: {sum(states)}"