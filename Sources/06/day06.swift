import Common
import Foundation

func ways_to_win(_ time: Int, _ record: Int) -> Int? {
    var l = 1, r = time / 2

    while l < r {
        let x = (l + r) / 2
        if x * (time - x) > record {
            r = x
        } else {
            l = x + 1
        }
    }

    return time - 2 * l + 1
}

@main
open class Day06: Common.Day<Int> {
    static func main() {
        Day06().run()
    }

    override open func part1(_ lines: [String]) -> Int {
        let races = parse_input(lines)
        return races.reduce(1) { p, v -> Int in p * ways_to_win(v.time, v.record)! }
    }

    override open func part2(_ lines: [String]) -> Int {
        let time = Common.substr_after(str: lines[0], c: ":").replacingOccurrences(of: " ", with: "")
        let record = Common.substr_after(str: lines[1], c: ":").replacingOccurrences(of: " ", with: "")
        return ways_to_win(Int(time)!, Int(record)!)!
    }

    func parse_input(_ lines: [String]) -> [(time: Int, record: Int)] {
        let times = Common.substr_after(str: lines[0], c: ":").split(separator: " ")
        let records = Common.substr_after(str: lines[1], c: ":").split(separator: " ")

        return zip(times, records).map { t, r -> (time: Int, record: Int) in (time: Int(t)!, record: Int(r)!) }
    }
}
