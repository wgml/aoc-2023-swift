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

enum Day06 {
    static func part1(_ lines: [String]) -> Int {
        let races = parse_input(lines)
        return races.reduce(1) { p, v -> Int in p * ways_to_win(v.time, v.record)! }
    }

    static func part2(_ lines: [String]) -> Int {
        let time = substr_after(str: lines[0], c: ":").replacingOccurrences(of: " ", with: "")
        let record = substr_after(str: lines[1], c: ":").replacingOccurrences(of: " ", with: "")
        return ways_to_win(Int(time)!, Int(record)!)!
    }

    static func parse_input(_ lines: [String]) -> [(time: Int, record: Int)] {
        let times = substr_after(str: lines[0], c: ":").split(separator: " ")
        let records = substr_after(str: lines[1], c: ":").split(separator: " ")

        return zip(times, records).map { t, r -> (time: Int, record: Int) in (time: Int(t)!, record: Int(r)!) }
    }
}
