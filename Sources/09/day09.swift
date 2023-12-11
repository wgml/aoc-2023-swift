import Common
import Foundation

func next_value(values: [Int]) -> Int {
    if values.allSatisfy({ v -> Bool in v == 0 }) {
        return 0
    }

    let differences = stride(from: 0, to: values.count - 1, by: 1).map { i -> Int in values[i + 1] - values[i] }
    return values.last! + next_value(values: differences)
}

@main
open class Day09: Common.Day<Int> {
    static func main() {
        Day09().run()
    }

    override open func part1(_ lines: [String]) -> Int {
        let sequences = parse_input(lines)
        return sequences.map { s -> Int in next_value(values: s) }.reduce(0, +)
    }

    override open func part2(_ lines: [String]) -> Int {
        let sequences = parse_input(lines)
        return sequences.map { s -> Int in next_value(values: s.reversed()) }.reduce(0, +)
    }

    func parse_input(_ lines: [String]) -> [[Int]] {
        return lines.map { l -> [Int] in l.split(separator: " ").map { n -> Int in Int(n)! } }
    }
}
