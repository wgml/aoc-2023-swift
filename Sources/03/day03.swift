import Common
import Foundation

let GEAR: Character = "*"

func parseInput(_ lines: [String]) -> ([XY: Int], [XY: Character]) {
    var numbers: [XY: Int] = [:]
    var symbols: [XY: Character] = [:]
    
    let width = lines.first!.count
    
    for (y, line) in lines.enumerated() {
        var x = 0
        
        var cur_number = 0
        var cur_len = 0
        while x < width {
            let c = line[line.index(line.startIndex, offsetBy: x)]
            if let digit = c.wholeNumberValue {
                cur_number = cur_number * 10+digit
                cur_len += 1
                x += 1
                continue
            }
            
            if cur_len > 0 {
                numbers[XY(x: x-cur_len, y: y)] = cur_number
                cur_number = 0
                cur_len = 0
            }
            
            if c != "." {
                symbols[XY(x: x, y: y)] = c
            }
            x += 1
        }
    }
    return (numbers, symbols)
}

func length_of(_ number: Int) -> Int {
    if number == 0 {
        return 1
    }
    return Int(log10f(Float(number)))+1
}

@main
open class Day03: Common.Day<Int> {
    static func main() {
        Day03().run()
    }
    
    override open func part1(_ lines: [String]) -> Int {
        let (numbers, symbols) = parseInput(lines)
        
        var result = 0
        for (xy, num) in numbers {
            let len = length_of(num)
            for y in xy.y-1 ... xy.y+1 {
                for x in xy.x-1 ... xy.x+len {
                    if symbols[XY(x: x, y: y)] != nil {
                        result += num
                    }
                }
            }
        }
        return result
    }

    override open func part2(_ lines: [String]) -> Int {
        let (numbers, symbols) = parseInput(lines)
        
        var gears: [XY: [Int]] = [:]
        
        for (xy, num) in numbers {
            let len = length_of(num)
            for y in xy.y-1 ... xy.y+1 {
                for x in xy.x-1 ... xy.x+len {
                    let xy = XY(x: x, y: y)
                    if symbols[xy] == GEAR {
                        if gears[xy] == nil {
                            gears[xy] = []
                        }
                        gears[XY(x: x, y: y)]!.append(num)
                    }
                }
            }
        }
        
        var result = 0
        for numbers in gears.values {
            if numbers.count == 2 {
                result += numbers[0] * numbers[1]
            }
        }
        return result
    }
}
