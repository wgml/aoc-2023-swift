import Common
import Foundation

struct State: Hashable {
    let pos: XY
    let i: Int

    public static func == (lhs: State, rhs: State) -> Bool {
        return lhs.pos == rhs.pos && (lhs.i % 2) == (rhs.i % 2)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(pos)
        hasher.combine(i % 2)
    }
}

func reachable_points(stones: [[Bool]], start: XY, steps: Int) -> Int {
    let directions = [XY.Up, XY.Down, XY.Left, XY.Right]
    var positions: Set<XY> = [start]
    var visited: Set<State> = [State(pos: start, i: 0)]

    let width = stones[0].count
    let height = stones.count

    for i in 1 ... steps {
        var new_positions: Set<XY> = []
        for p in positions {
            for d in directions {
                let new_p = p + d
                let px = (new_p.x % width + width) % width
                let py = (new_p.y % height + height) % height

                if stones[py][px] {
                    continue
                }
                let state = State(pos: new_p, i: i)
                if visited.contains(state) {
                    continue
                }
                visited.insert(state)
                new_positions.insert(new_p)
            }
        }
        positions = new_positions
    }
    return visited.filter { $0.i % 2 == steps % 2 }.map { $0.pos }.reduce(into: Set<XY>()) { $0.insert($1) }.count
}

@main
open class Day21: Common.Day<Int> {
    static func main() {
        Day21().run()
    }

    override open func part1(_ lines: [String]) -> Int {
        let (stones, start) = parse_input(lines)
        return reachable_points(stones: stones, start: start, steps: 64)
    }

    override open func part2(_ lines: [String]) -> Int {
        let (stones, start) = parse_input(lines)
        let width = stones[0].count
        let half_width = width / 2
        let cycles = 26501365 / width
        let xs = [half_width, width + half_width, 2 * width + half_width]
        let ys = xs.map { reachable_points(stones: stones, start: start, steps: $0) }
        return ys[0] + cycles * (ys[1] - ys[0] + (cycles - 1) * ((ys[2] - 2 * ys[1] + ys[0]) / 2))
    }

    func parse_input(_ lines: [String]) -> (rocks: [[Bool]], start: XY) {
        var start: XY?
        var rocks = Array(repeating: Array(repeating: false, count: lines[0].count), count: lines.count)

        for (y, line) in lines.enumerated() {
            for (x, c) in line.enumerated() {
                switch c {
                case "S": start = XY(x: x, y: y)
                case "#": rocks[y][x] = true
                default: continue
                }
            }
        }

        return (rocks: rocks, start: start!)
    }
}
