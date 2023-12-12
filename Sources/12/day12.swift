import Common
import Foundation

struct Record {
    enum Element {
        static let Absent: Character = "."
        static let Present: Character = "#"
        static let Maybe: Character = "?"
    }

    let elements: [Character]
    let groups: [Int]
}

struct State: Hashable {
    let pos, group, len: Int

    public static func == (lhs: State, rhs: State) -> Bool {
        return lhs.pos == rhs.pos && lhs.group == rhs.group && lhs.len == rhs.len
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(pos)
        hasher.combine(group)
        hasher.combine(len)
    }
}

func do_count_arrangements(cache: inout [State: Int], record: Record, pos: Int, current_group: Int, current_group_length: Int) -> Int {
    if pos == record.elements.count {
        if current_group == record.groups.count && current_group_length == 0 {
            return 1
        } else {
            return 0
        }
    }

    var sum = 0
    if record.elements[pos] == Record.Element.Absent || record.elements[pos] == Record.Element.Maybe {
        if current_group < record.groups.count && current_group_length == record.groups[current_group] {
            sum += count_arrangements(cache: &cache, record: record, pos: pos + 1, current_group: current_group + 1, current_group_length: 0)
        }
        if current_group_length == 0 {
            sum += count_arrangements(cache: &cache, record: record, pos: pos + 1, current_group: current_group, current_group_length: 0)
        }
    }

    if record.elements[pos] == Record.Element.Present || record.elements[pos] == Record.Element.Maybe {
        sum += count_arrangements(cache: &cache, record: record, pos: pos + 1, current_group: current_group, current_group_length: current_group_length + 1)
    }

    return sum
}

func count_arrangements(cache: inout [State: Int], record: Record, pos: Int, current_group: Int, current_group_length: Int) -> Int {
    let state = State(pos: pos, group: current_group, len: current_group_length)

    if let res = cache[state] {
        return res
    }

    let result = do_count_arrangements(cache: &cache, record: record, pos: pos, current_group: current_group, current_group_length: current_group_length)
    cache[state] = result
    return result
}

func count_arrangements(record: Record) -> Int {
    var cache: [State: Int] = [:]
    var parts_terminated = record.elements
    parts_terminated.append(Record.Element.Absent)
    let res = count_arrangements(cache: &cache, record: Record(elements: parts_terminated, groups: record.groups), pos: 0, current_group: 0, current_group_length: 0)
    return res
}

func unfold(record: Record) -> Record {
    var new_elements: [Character] = []
    for _ in 1 ... 4 {
        new_elements.append(contentsOf: record.elements)
        new_elements.append(Record.Element.Maybe)
    }
    new_elements.append(contentsOf: record.elements)

    let new_groups = Array(repeating: record.groups, count: 5).flatMap { $0 }
    return Record(elements: new_elements, groups: new_groups)
}

@main
open class Day12: Common.Day<Int> {
    static func main() {
        Day12().run()
    }

    override open func part1(_ lines: [String]) -> Int {
        return parse_input(lines).map { count_arrangements(record: $0) }.reduce(0, +)
    }

    override open func part2(_ lines: [String]) -> Int {
        return parse_input(lines).map { unfold(record: $0) }.map { count_arrangements(record: $0) }.reduce(0, +)
    }

    func parse_input(_ lines: [String]) -> [Record] {
        var records: [Record] = []
        for line in lines {
            let parts = line.split(separator: " ")
            records.append(Record(elements: parts[0].map { $0 }, groups: parts[1].split(separator: ",").map { Int($0)! }))
        }
        return records
    }
}
