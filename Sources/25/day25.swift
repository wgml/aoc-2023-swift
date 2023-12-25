import Common
import Foundation

struct Edge: Hashable {
    let a, b: String

    static func == (lhs: Edge, rhs: Edge) -> Bool {
        return lhs.a == rhs.a && lhs.b == rhs.b
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(a)
        hasher.combine(b)
    }
}

// https://en.wikipedia.org/wiki/Karger%27s_algorithm
func find_cut(V: Set<String>, E: Set<Edge>) -> Int {
    while true {
        var subsets: [Set<String>] = V.map { Set([$0]) }
        while subsets.count > 2 {
            let rand_edge = E.randomElement()!
            let s1 = subsets.firstIndex(where: { $0.contains(rand_edge.a) })!
            let s2 = subsets.firstIndex(where: { $0.contains(rand_edge.b) })!
            if s1 != s2 {
                var subset = subsets[s1]
                subset.formUnion(subsets[s2])
                subsets.remove(at: subsets.firstIndex(where: { $0.contains(rand_edge.a) })!)
                subsets.remove(at: subsets.firstIndex(where: { $0.contains(rand_edge.b) })!)
                subsets.append(subset)
            }
        }
        var sets = 0
        for e in E {
            let s1 = subsets.firstIndex(where: { $0.contains(e.a) })
            let s2 = subsets.firstIndex(where: { $0.contains(e.b) })
            if s1 != s2 {
                sets += 1
            }
        }
        if sets < 4 {
            return subsets.map { $0.count }.reduce(1, *)
        }
    }
    fatalError("Unreachable")
}

@main
open class Day25: Common.Day<Int> {
    static func main() {
        Day25().run()
    }

    override open func part1(_ lines: [String]) -> Int {
        let (V, E) = parse_input(lines)
        return find_cut(V: V, E: E)
    }

    override open func part2(_ lines: [String]) -> Int {
        return 50
    }

    func parse_input(_ lines: [String]) -> (V: Set<String>, E: Set<Edge>) {
        var V: Set<String> = []
        var E: Set<Edge> = []

        for line in lines {
            let parts = line.split(separator: " ")
            let from = String(parts[0].prefix(3))
            let to = parts[1 ..< parts.count].map { String($0) }
            V.formUnion(to)
            V.insert(from)

            for e in to {
                E.insert(Edge(a: from, b: e))
            }
        }

        return (V: V, E: E)
    }
}
