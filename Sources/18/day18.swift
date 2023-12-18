import Common
import Foundation

typealias XY = Common.XY

struct Instruction {
    let dir: XY
    let dist: Int
    let color: String

    static let Up = XY(x: 0, y: -1)
    static let Down = XY(x: 0, y: 1)
    static let Left = XY(x: -1, y: 0)
    static let Right = XY(x: 1, y: 0)
}

func dir_and_dist(_ instr: Instruction) -> (XY, Int) {
    let dir = switch instr.color.last! {
    case "0": Instruction.Right
    case "1": Instruction.Down
    case "2": Instruction.Left
    case "3": Instruction.Up
    default: fatalError("Unhandled \(instr.color.last!)")
    }
    let dist_str = instr.color[instr.color.startIndex ... instr.color.index(instr.color.startIndex, offsetBy: 4)]
    return (dir, Int(dist_str, radix: 16)!)
}

func calculate_dig(instructions: [Instruction], dir_and_dist_fn: (Instruction) -> (XY, Int)) -> Int {
    var current = XY(x: 0, y: 0)
    var points = [current]

    for i in instructions {
        let (dir, dist) = dir_and_dist_fn(i)
        current += dir * dist
        points.append(current)
    }

    var area = 0
    var perimeter = 0
    for i in 0 ..< points.count {
        let p1 = points[i]
        let p2 = points[(i + 1) % points.count]
        area += p1.x * p2.y - p2.x * p1.y
        perimeter += abs(p1.x - p2.x) + abs(p1.y - p2.y)
    }

    return (abs(area) + perimeter) / 2 + 1
}

@main
open class Day18: Common.Day<Int> {
    static func main() {
        Day18().run()
    }

    override open func part1(_ lines: [String]) -> Int {
        let instructions = parse_input(lines)
        return calculate_dig(instructions: instructions) {
            instr in (instr.dir, instr.dist)
        }
    }

    override open func part2(_ lines: [String]) -> Int {
        let instructions = parse_input(lines)
        return calculate_dig(instructions: instructions, dir_and_dist_fn: dir_and_dist)
    }

    func parse_input(_ lines: [String]) -> [Instruction] {
        var instructions: [Instruction] = []
        for line in lines {
            let parts = line.split(separator: " ")
            let dir = switch parts[0] {
            case "U": Instruction.Up
            case "D": Instruction.Down
            case "L": Instruction.Left
            case "R": Instruction.Right
            default: fatalError("Unexpected: \(parts[0])")
            }
            let dist = Int(parts[1])!
            let color = parts[2][parts[2].index(parts[2].startIndex, offsetBy: 2) ... parts[2].index(parts[2].startIndex, offsetBy: 7)]
            instructions.append(Instruction(dir: dir, dist: dist, color: String(color)))
        }
        return instructions
    }
}
