import Common
import Foundation

enum Tile: Equatable {
    case Path
    case Forest
    case Slope(dir: XY)
}

typealias Map = [[Tile]]

func neighbours(map: Map, pos: XY) -> [XY] {
    switch map[pos.y][pos.x] {
    case .Slope(let dir):
        return [pos + dir]
    case .Path:
        var ns: [XY] = []
        for d in [XY.Up, XY.Right, XY.Down, XY.Left] {
            let c = pos + d
            if c.x >= 0 && c.x < map[0].count && c.y >= 0 && c.y < map.count && map[c.y][c.x] != .Forest {
                ns.append(c)
            }
        }
        return ns
    default: return []
    }
}

func bfs(map: Map, start: XY, end: XY, intersections: Set<XY>) -> Int? {
    var queue: [XY] = [start]
    var costs: [XY: Int] = [start: 0]

    while !queue.isEmpty {
        let candidate = queue.removeLast()
        if candidate == end {
            return costs[end]!
        }
        if candidate != start, intersections.contains(candidate) {
            continue
        }
        for e in neighbours(map: map, pos: candidate) {
            let cost = costs[candidate]! + 1
            let known_cost = costs[e]
            if (known_cost ?? Int.max) >= cost {
                costs[e] = cost
                queue.append(e)
            }
        }
    }
    return nil
}

func longest_hike(map: Map) -> Int {
    let start = XY(x: map[0].firstIndex(where: { t in t == .Path })!, y: 0)
    let end = XY(x: map.last!.firstIndex(where: { t in t == .Path })!, y: map.count - 1)

    var queue: [(XY, Set<XY>)] = [(start, [start])]
    var costs: [XY: Int] = [start: 0]
    while !queue.isEmpty {
        let (pos, path) = queue.removeLast()
        if pos == end {
            continue
        }

        for c in neighbours(map: map, pos: pos) {
            if path.contains(c) {
                continue
            }

            let cost = costs[pos]! + 1

            if let prev_cost = costs[c] {
                if prev_cost >= cost {
                    continue
                }
            }
            costs[c] = cost
            var new_path = path
            new_path.insert(c)
            queue.append((c, new_path))
        }
    }

    return costs[end]!
}

func longest_hike_no_slopes(map: Map) -> Int {
    let start = XY(x: map[0].firstIndex(where: { t in t == .Path })!, y: 0)
    let end = XY(x: map.last!.firstIndex(where: { t in t == .Path })!, y: map.count - 1)

    var intersections: Set<XY> = [start, end]
    var graph: [XY: [XY: Int]] = [start: [:], end: [:]]

    for (y, r) in map.enumerated() {
        for (x, p) in r.enumerated() {
            if p != .Path {
                continue
            }
            let xy = XY(x: x, y: y)
            if neighbours(map: map, pos: xy).count > 2 {
                intersections.insert(xy)
                graph[xy] = [:]
            }
        }
    }

    for node in graph.keys {
        for intersection in intersections {
            if node == intersection {
                continue
            }

            if graph[node]![intersection] != nil {
                continue
            }

            if let dist = bfs(map: map, start: node, end: intersection, intersections: intersections) {
                graph[node]![intersection] = dist
                graph[intersection]![node] = dist
            }
        }
    }

    var queue: [(XY, Int, Set<XY>)] = [(start, 0, [])]
    var max_cost = 0
    while !queue.isEmpty {
        var (pos, len, path) = queue.removeLast()
        if pos == end {
            max_cost = max(max_cost, len)
            continue
        }
        path.insert(pos)
        for (next, c) in graph[pos]! {
            if path.contains(next) {
                continue
            }

            let cost = len + c
            queue.append((next, cost, path))
        }
    }

    return max_cost
}

@main
open class Day23: Common.Day<Int> {
    static func main() {
        Day23().run()
    }

    override open func part1(_ lines: [String]) -> Int {
        let map = parse_input(lines)
        return longest_hike(map: map)
    }

    override open func part2(_ lines: [String]) -> Int {
        let map = parse_input(lines)
        return longest_hike_no_slopes(map: map)
    }

    func parse_input(_ lines: [String]) -> Map {
        var map: Map = []

        for line in lines {
            var row: [Tile] = []
            for c in line {
                switch c {
                case ".": row.append(.Path)
                case "#": row.append(.Forest)
                case ">": row.append(.Slope(dir: XY.Right))
                case "v": row.append(.Slope(dir: XY.Down))
                case "<": row.append(.Slope(dir: XY.Left))
                case "^": row.append(.Slope(dir: XY.Up))
                default: fatalError("Unhandled \(c)")
                }
            }
            map.append(row)
        }
        return map
    }
}
