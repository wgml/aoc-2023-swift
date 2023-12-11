import Common
import Foundation

struct Network {
    let instructions: [Int]
    let nodes: [String: [String]]
}

func find_steps_required(network: Network, start: String, end: (String) -> Bool) -> Int {
    var current = start
    var steps = 0

    while !end(current) {
        current = network.nodes[current]![network.instructions[steps % network.instructions.count]]
        steps += 1
    }

    return steps
}

@main
open class Day08: Common.Day<Int> {
    static func main() {
        Day08().run()
    }

    override open func part1(_ lines: [String]) -> Int {
        let network = parse_input(lines)

        return find_steps_required(network: network, start: "AAA", end: { c -> Bool in c == "ZZZ" })
    }

    override open func part2(_ lines: [String]) -> Int {
        let network = parse_input(lines)

        let starts = network.nodes.keys.filter { i -> Bool in i.last == "A" }
        let steps = starts.map { s -> Int in find_steps_required(network: network, start: s, end: { c -> Bool in c.last == "Z" }) }

        return steps.reduce(1) { a, b -> Int in
            lcm(a, b)
        }
    }

    func parse_input(_ lines: [String]) -> Network {
        let instructions = lines[0].map { i -> Int in i == "L" ? 0 : 1 }
        var nodes: [String: [String]] = [:]
        for l in lines[2...] {
            let lb = l.index(l.startIndex, offsetBy: 7)
            let le = l.index(l.startIndex, offsetBy: 9)
            let rb = l.index(l.startIndex, offsetBy: 12)
            let re = l.index(l.startIndex, offsetBy: 14)

            nodes[String(l.prefix(3))] = [String(l[lb...le]), String(l[rb...re])]
        }

        return Network(instructions: instructions, nodes: nodes)
    }
}
