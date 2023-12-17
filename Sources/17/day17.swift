import Common
import Foundation

struct State: Comparable {
    let pos: XY
//    let from: XY
    let dir: XY
    let in_this_dir: Int
    let cost: Int

    static let Up = XY(x: 0, y: -1)
    static let Down = XY(x: 0, y: 1)
    static let Left = XY(x: -1, y: 0)
    static let Right = XY(x: 1, y: 0)

    public static func < (lhs: State, rhs: State) -> Bool {
        if lhs.cost != rhs.cost {
            return lhs.cost < rhs.cost
        }
        if lhs.pos != rhs.pos {
            return (lhs.pos.x + lhs.pos.y) > (rhs.pos.x + rhs.pos.y)
        }

        if lhs.dir != rhs.dir {
            return (lhs.dir.x + lhs.dir.y) > (rhs.dir.x + rhs.dir.y)
        }

        return false
    }
}

struct HashableState: Hashable {
    let state: State

    public static func == (lhs: HashableState, rhs: HashableState) -> Bool {
        return lhs.state.pos == rhs.state.pos && lhs.state.dir == rhs.state.dir && lhs.state.in_this_dir == rhs.state.in_this_dir
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(state.pos)
        hasher.combine(state.dir)
        hasher.combine(state.in_this_dir)
    }
}

func poor_mans_astar(map: [[Int]], min_in_dir: Int, max_in_dir: Int) -> Int {
    func in_bounds(_ pos: XY) -> Bool {
        return pos.x >= 0 && pos.x < map[0].count && pos.y >= 0 && pos.y < map.count
    }

    func is_reversing(_ a: XY, _ b: XY) -> Bool {
        return a.x == -b.x && a.y == -b.y
    }

    let destination = XY(x: map[0].count - 1, y: map.count - 1)
    var visited: Set<HashableState> = []
    var queue = PriorityQueue<State>(ascending: true, startingValues: [State(pos: XY(x: 0, y: 0), dir: State.Down, in_this_dir: 0, cost: -map[0][0])])

    while let current = queue.pop() {
        if current.pos == destination {
            return current.cost + map[destination.y][destination.x]
        }
        let id = HashableState(state: current)
        if !visited.insert(id).inserted {
            continue
        }

        for dir in [State.Up, State.Down, State.Left, State.Right] {
            let next = current.pos + dir
            if is_reversing(current.dir, dir) || !in_bounds(next) {
                continue
            }
            if dir == current.dir {
                if current.in_this_dir < max_in_dir {
                    queue.push(State(pos: next, dir: dir, in_this_dir: current.in_this_dir + 1, cost: current.cost + map[current.pos.y][current.pos.x]))
                }
            } else {
                if current.in_this_dir >= min_in_dir {
                    queue.push(State(pos: next, dir: dir, in_this_dir: 1, cost: current.cost + map[current.pos.y][current.pos.x]))
                }
            }
        }
    }
    fatalError("Unreachable")
}

@main
open class Day17: Common.Day<Int> {
    static func main() {
        Day17().run()
    }

    override open func part1(_ lines: [String]) -> Int {
        let map = parse_input(lines)
        return poor_mans_astar(map: map, min_in_dir: 0, max_in_dir: 3)
    }

    override open func part2(_ lines: [String]) -> Int {
        let map = parse_input(lines)
        return poor_mans_astar(map: map, min_in_dir: 4, max_in_dir: 10)
    }

    func parse_input(_ lines: [String]) -> [[Int]] {
        return lines.map { line in line.map { c in c.wholeNumberValue! } }
    }
}
