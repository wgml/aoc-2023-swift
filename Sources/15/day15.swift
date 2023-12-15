import Common
import Foundation

func hash_value(_ str: String) -> Int {
    var hash = Int(0)
    for c in str {
        hash = ((hash + Int(c.asciiValue!)) * 17) % 256
    }
    return hash
}

func make_step(_ str: String.SubSequence) -> Step {
    if str.last! == "-" {
        return Step(text: String(str), op: Step.Op.Remove(label: String(str[str.startIndex..<str.index(str.endIndex, offsetBy: -1)])))
    } else {
        return Step(text: String(str), op: Step.Op.Add(label: String(str[str.startIndex..<str.index(str.endIndex, offsetBy: -2)]), focal: str.last!.wholeNumberValue!))
    }
}

struct Step {
    enum Op {
        case Add(label: String, focal: Int)
        case Remove(label: String)
    }

    let text: String
    let op: Op
    var hash: Int {
        hash_value(text)
    }
}

struct Lens {
    let label: String
    let focal: Int

    var hash: Int {
        hash_value(label)
    }
}

func equal_by_label(label: String) -> (Lens) -> Bool {
    return { e in e.label == label }
}

@main
open class Day15: Common.Day<Int> {
    static func main() {
        Day15().run()
    }

    override open func part1(_ lines: [String]) -> Int {
        return parse_input(lines).map { $0.hash }.reduce(0, +)
    }

    override open func part2(_ lines: [String]) -> Int {
        let steps = parse_input(lines)

        var boxes: [[Lens]] = Array(repeating: [], count: 256)
        for step in steps {
            switch step.op {
            case let .Add(label, focal):
                let lens = Lens(label: label, focal: focal)
                let box_id = lens.hash
                if let existing = boxes[box_id].firstIndex(where: equal_by_label(label: label)) {
                    boxes[box_id][existing] = lens
                } else {
                    boxes[box_id].append(lens)
                }
            case let .Remove(label):
                let box_id = hash_value(label)
                boxes[box_id].removeAll(where: equal_by_label(label: label))
            }
        }

        var focal = 0
        for (i, box) in boxes.enumerated() {
            for (j, lens) in box.enumerated() {
                focal += (i + 1) * (j + 1) * lens.focal
            }
        }
        return focal
    }

    func parse_input(_ lines: [String]) -> [Step] {
        return lines.first!.split(separator: ",").map { make_step($0) }
    }
}
