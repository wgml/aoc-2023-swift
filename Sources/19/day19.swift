import Common
import Foundation

struct Range {
    let from, to: Int

    func contains(_ v: Int) -> Bool {
        return v >= from && v <= to
    }

    static func all() -> Range {
        return Range(from: 1, to: 4000)
    }

    var empty: Bool {
        return from > to
    }

    func intersect(_ other: Range) -> [Range] {
        let range = Range(from: max(other.from, from), to: min(other.to, to))
        if range.empty {
            return []
        }
        return [range]
    }

    func difference(_ other: Range) -> [Range] {
        let ranges = [intersect(Range(from: 1, to: other.from - 1)), intersect(Range(from: other.to + 1, to: 4000))]
        return ranges.reduce([], +).filter { !$0.empty }
    }
}

struct Predicate {
    let category: String?
    let range: Range

    func evaluate(_ part: Part) -> Bool {
        if category == nil {
            return true
        }
        return range.contains(part[category!]!)
    }

    func intersect(_ ranges: [String: [Range]]) -> [String: [Range]] {
        guard let cat = category else {
            return ranges
        }
        var new_ranges: [Range] = []
        for r in ranges[cat]! {
            new_ranges.append(contentsOf: r.intersect(range))
        }

        if new_ranges.isEmpty {
            return [:]
        }
        var all_new_ranges = ranges
        all_new_ranges[cat] = new_ranges
        return all_new_ranges
    }

    func difference(_ ranges: [String: [Range]]) -> [String: [Range]] {
        guard let cat = category else {
            return [:]
        }
        var new_ranges: [Range] = []
        for r in ranges[cat]! {
            new_ranges.append(contentsOf: r.difference(range))
        }

        if new_ranges.isEmpty {
            return ranges
        }
        var all_new_ranges = ranges
        all_new_ranges[cat] = new_ranges
        return all_new_ranges
    }

    static func always() -> Predicate {
        return Predicate(category: nil, range: Range(from: 1, to: 4000))
    }
}

enum Rule {
    case Accept(predicate: Predicate)
    case Reject(predicate: Predicate)
    case Delegate(predicate: Predicate, next: String)
}

typealias Part = [String: Int]
typealias Workflow = [Rule]

func combinations_of(ranges: [String: [Range]]) -> Int {
    return ranges.values.map { rs in rs.map { r in r.to - r.from + 1 }.reduce(0, +) }.reduce(1, *)
}

func do_evaluate_ranges(current: String, workflows: [String: Workflow], ranges: [String: [Range]]) -> Int {
    var the_ranges = ranges
    var result = 0
    for rule in workflows[current]! {
        switch rule {
        case .Accept(let pred):
            let intersection = pred.intersect(the_ranges)
            if !intersection.isEmpty {
                result += combinations_of(ranges: intersection)
            }
            the_ranges = pred.difference(the_ranges)
        case .Reject(let pred):
            let difference = pred.difference(the_ranges)
            the_ranges = difference
        case .Delegate(let pred, let next):
            let intersection = pred.intersect(the_ranges)
            if !intersection.isEmpty {
                result += do_evaluate_ranges(current: next, workflows: workflows, ranges: intersection)
            }
            the_ranges = pred.difference(the_ranges)
        }
    }

    return result
}

func evaluate_ranges(workflows: [String: Workflow], ranges: [String: [Range]]) -> Int {
    return do_evaluate_ranges(current: "in", workflows: workflows, ranges: ranges)
}

func evaluate(part: Part, workflows: [String: Workflow]) -> Bool {
    var current_workflow = "in"

    while true {
        eval_rules: for rule in workflows[current_workflow]! {
            switch rule {
            case .Accept(let pred): if pred.evaluate(part) { return true }
            case .Reject(let pred): if pred.evaluate(part) { return false }
            case .Delegate(let pred, let next): if pred.evaluate(part) {
                    current_workflow = next
                    break eval_rules
                }
            }
        }
    }
}

func rate(part: Part) -> Int {
    return part.values.reduce(0, +)
}

@main
open class Day19: Common.Day<Int> {
    static func main() {
        Day19().run()
    }

    override open func part1(_ lines: [String]) -> Int {
        let (workflows, parts) = parse_input(lines)
        return parts.filter { evaluate(part: $0, workflows: workflows) }.map { rate(part: $0) }.reduce(0, +)
    }

    override open func part2(_ lines: [String]) -> Int {
        let (workflows, _) = parse_input(lines)
        return evaluate_ranges(workflows: workflows, ranges: ["x": [Range.all()], "m": [Range.all()], "a": [Range.all()], "s": [Range.all()]])
    }

    func parse_input(_ lines: [String]) -> ([String: Workflow], [Part]) {
        var workflows: [String: Workflow] = [:]
        var parts: [Part] = []
        for line in lines {
            if line == "" {
                continue
            } else if line.starts(with: "{") {
                // Parse part
                let line_parts = line[line.index(after: line.startIndex) ..< line.index(before: line.endIndex)].split(separator: ",")
                parts.append(line_parts.reduce(into: Part()) {
                    part, p in
                    let kv = p.split(separator: "=")
                    part[String(kv[0])] = Int(kv[1])!
                })
            } else {
                // Parse workflow
                let name_end_index = line.firstIndex(where: { c in c == "{" })!
                let rules_end = line.firstIndex(where: { c in c == "}" })!
                let name = line[line.startIndex ..< name_end_index]

                var rules: [Rule] = []
                for r in line[line.index(after: name_end_index) ..< rules_end].split(separator: ",") {
                    let pred_next = r.split(separator: ":")
                    let predicate: Predicate
                    if pred_next.count == 1 {
                        predicate = .always()
                    } else {
                        let pred_str = pred_next.first!
                        let category = String(pred_str[pred_str.startIndex])
                        let op = pred_str[pred_str.index(pred_str.startIndex, offsetBy: 1)]
                        let value = Int(pred_str[pred_str.index(pred_str.startIndex, offsetBy: 2)...])!
                        predicate = switch op {
                        case ">": Predicate(category: category, range: Range(from: value + 1, to: 4000))
                        case "<": Predicate(category: category, range: Range(from: 1, to: value - 1))
                        default: fatalError("unhandled op: \(op)")
                        }
                    }
                    let rule = switch pred_next.last! {
                    case "A": Rule.Accept(predicate: predicate)
                    case "R": Rule.Reject(predicate: predicate)
                    default: Rule.Delegate(predicate: predicate, next: String(pred_next.last!))
                    }
                    rules.append(rule)
                }
                workflows[String(name)] = rules
            }
        }

        return (workflows, parts)
    }
}
