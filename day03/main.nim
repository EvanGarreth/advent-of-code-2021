import strformat, strutils, unittest, sequtils, sugar

type
  DiagnosticReport = ref object
    data: seq[int]
    bits: int
    gammaRate: int
    epsilonRate: int
    oxygenGeneratorRating: int
    c02ScrubberRating: int

func powerConsumption(dr: DiagnosticReport): int =
  dr.gammaRate * dr.epsilonRate

func lifeSupportRating(dr: DiagnosticReport): int =
  dr.oxygenGeneratorRating * dr.c02ScrubberRating

func parseData(dr: DiagnosticReport): void =
  var
    halfDataLen = int((len(dr.data) + 1) / 2)
    mcbs = collect(newSeq):
      for i in 0..<dr.bits: 0
    countOnes = collect(newSeq):
      for i in 0..<dr.bits: 0

  for num in dr.data:
    for pos in 0 ..< dr.bits:
      if ((num shr pos) and 1) == 0b1:
        countOnes[pos] += 1

  for pos in 0 ..< dr.bits:
    mcbs[pos] = if (countOnes[pos] < halfDataLen): 0b0 else: 0b1

  block:
    # arrays are reversed from the bits in the number
    # eg: 0b1011 is [1,1,0,1]
    for pos in countdown(dr.bits-1, 0):
      # epsilon uses least common bit, gamma uses most common
      # only need to make a change in instances where the [m/l]cb results in a 1 bit for the rate
      if mcbs[pos] == 0:
        dr.epsilonRate = dr.epsilonRate or (1 shl pos)
      else:
        dr.gammaRate = dr.gammaRate or (1 shl pos)

  block:
    var 
      oxygenCandidates = dr.data
      c02Candidates = dr.data
      pos = dr.bits-1

    # To find oxygen generator rating, determine the most common value (0 or 1) in the current bit position,
    #   and keep only numbers with that bit in that position. If 0 and 1 are equally common, 
    #   keep values with a 1 in the position being considered.
    # To find CO2 scrubber rating, determine the least common value (0 or 1) in the current bit position,
    #   and keep only numbers with that bit in that position. If 0 and 1 are equally common,
    #   keep values with a 0 in the position being considered.
    #
    # repeat until a single candidate remains
    while len(oxygenCandidates) > 1:
      let halfCandidatesLen = int((len(oxygenCandidates) + 1)/2)
      var
        mcb: int
        ones = 0

      for num in oxygenCandidates:
        if ((num shr pos) and 1) == 0b1:
          ones += 1

      mcb = if (ones >= halfCandidatesLen): 0b1 else: 0b0
      oxygenCandidates = oxygenCandidates.filter(proc (num:int): bool = ((num shr pos) and 1) == mcb)

      pos -= 1

    pos = dr.bits-1
    while len(c02Candidates) > 1:
      let halfCandidatesLen = int((len(c02Candidates) + 1)/2)
      var
        lcb: int
        ones = 0
      
      for num in c02Candidates:
        if ((num shr pos) and 1) == 0b1:
          ones += 1

      lcb = if (ones < halfCandidatesLen): 0b1 else: 0b0
      c02Candidates = c02Candidates.filter(proc (num:int): bool = ((num shr pos) and 1) == lcb)

      pos -= 1

    dr.oxygenGeneratorRating = oxygenCandidates[0]
    dr.c02ScrubberRating = c02Candidates[0]

proc newDiagnosticReport(data: seq[int], bits: int): DiagnosticReport =
  new result
  result.data = data
  result.bits = bits
  result.gammaRate = 0
  result.epsilonRate = 0
  result.oxygenGeneratorRating = 0
  result.c02ScrubberRating = 0

  result.parseData()
  return result

when is_main_module:
  let
    file = readFile("input.txt").strip().splitLines()
    bits = len(file[0]) # cheaply get the number of bits to iterate over
    data = file.map(parseBinInt)

  var dr = newDiagnosticReport(data, bits)

  block part1:
    echo fmt"pt1 gammaRate: {dr.gammaRate}, epsilonRate: {dr.epsilonRate}, powerConsumption: {dr.powerConsumption}"

  block part2:
    echo fmt"pt2 oxygenGeneratorRating: {dr.oxygenGeneratorRating}, c02ScrubberRating: {dr.c02ScrubberRating}, lifeSupportRating: {dr.lifeSupportRating}"


suite "Sample Input":
  setup:
    const input = @[
      0b00100,
      0b11110,
      0b10110,
      0b10111,
      0b10101,
      0b01111,
      0b00111,
      0b11100,
      0b10000,
      0b11001,
      0b00010,
      0b01010,
    ]
  
  test "part1":
    let dr = newDiagnosticReport(input, 5)

    assert dr.gammaRate == 22
    assert dr.epsilonRate == 9
    assert dr.powerConsumption == 198
  
  test "part2":
    let dr = newDiagnosticReport(input, 5)
  
    assert dr.oxygenGeneratorRating == 23
    assert dr.c02ScrubberRating == 10
    assert dr.lifeSupportRating == 230
