import Common
import Foundation

struct XYZ: Hashable {
    var x, y, z: Int

    public static func == (lhs: XYZ, rhs: XYZ) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
        hasher.combine(z)
    }
}

struct Brick {
    let id: Int
    var p1, p2: XYZ

    var supports: Set<Int> = []
    var supported_by: Set<Int> = []

    static func parse(_ id: Int, _ str: String) -> Brick {
        let parts = str.split(separator: "~")
        let mins = parts[0].split(separator: ",").map { Int($0)! }
        let maxes = parts[1].split(separator: ",").map { Int($0)! }
        return Brick(id: id,
                     p1: XYZ(x: mins[0], y: mins[1], z: mins[2]),
                     p2: XYZ(x: maxes[0], y: maxes[1], z: maxes[2]))
    }

    func occupied() -> [XYZ] {
        var positions: [XYZ] = []
        for x in p1.x...p2.x {
            for y in p1.y...p2.y {
                for z in p1.z...p2.z {
                    positions.append(XYZ(x: x, y: y, z: z))
                }
            }
        }
        return positions
    }

    func base() -> [XYZ] {
        var positions: [XYZ] = []

        for x in p1.x...p2.x {
            for y in p1.y...p2.y {
                positions.append(XYZ(x: x, y: y, z: p1.z))
            }
        }

        return positions
    }

    func below() -> [XYZ] {
        var positions: [XYZ] = []
        if p1.z == 1 {
            return positions
        }

        for x in p1.x...p2.x {
            for y in p1.y...p2.y {
                positions.append(XYZ(x: x, y: y, z: p1.z-1))
            }
        }

        return positions
    }

    mutating func fall(dz: Int) {
        p1.z -= dz
        p2.z -= dz
    }

    mutating func add_supported(_ id: Int) {
        supports.insert(id)
    }

    mutating func add_supporter(_ id: Int) {
        supported_by.insert(id)
    }
}

typealias Space = [[[Int?]]]

extension Space {
    func get(_ pos: XYZ) -> Int? {
        return self[pos.z][pos.y][pos.x]
    }

    mutating func set(_ pos: XYZ, _ v: Int?) {
        self[pos.z][pos.y][pos.x] = v
    }
}

func fall_distance(brick: Brick, space: Space) -> Int {
    let z = brick.p1.z
    let base = brick.base()
    for i in (0...z-1).reversed() {
        if i == 0 {
            return z-1
        }
        for p in base {
            var moved = p
            moved.z = i
            if space.get(moved) != nil {
                return z-i-1
            }
        }
    }
    fatalError("unreachable")
}

func just_fall(bricks: [Brick], space: Space) -> ([Brick], Space, Int) {
    var new_space = space
    var new_bricks = bricks

    var visited: Set<Int> = []
    var fallen = 0
    for z in 2...new_space.count-1 {
        for y in 0...new_space[z].count-1 {
            for x in 0...new_space[z][y].count-1 {
                let pos = XYZ(x: x, y: y, z: z)
                guard let id = new_space.get(pos) else {
                    continue
                }

                if visited.contains(id) {
                    continue
                }
                visited.insert(id)

                let dz = fall_distance(brick: new_bricks[id], space: new_space)
                if dz != 0 {
                    for p in new_bricks[id].occupied() {
                        new_space.set(p, nil)
                    }
                    new_bricks[id].fall(dz: dz)
                    for p in new_bricks[id].occupied() {
                        new_space.set(p, id)
                    }
                    fallen += 1
                }
            }
        }
    }
    return (new_bricks, new_space, fallen)
}

func fall_and_settle(bricks: [Brick], space: Space) -> ([Brick], Space) {
    var (new_bricks, new_space, _) = just_fall(bricks: bricks, space: space)

    for id in 0...new_bricks.count-1 {
        for p in new_bricks[id].below() {
            if let id2 = new_space.get(p) {
                new_bricks[id].add_supporter(id2)
                new_bricks[id2].add_supported(id)
            }
        }
    }
    return (new_bricks, new_space)
}

@main
open class Day22: Common.Day<Int> {
    static func main() {
        Day22().run()
    }

    override open func part1(_ lines: [String]) -> Int {
        var (bricks, space) = parse_input(lines)
        (bricks, space) = fall_and_settle(bricks: bricks, space: space)

        var can_be_removed = 0
        for b in bricks {
            var redundant = true
            for supports in b.supports {
                if bricks[supports].supported_by.count == 1 {
                    redundant = false
                    break
                }
            }
            if redundant {
                can_be_removed += 1
            }
        }

        return can_be_removed
    }

    override open func part2(_ lines: [String]) -> Int {
        var (bricks, space) = parse_input(lines)
        (bricks, space, _) = just_fall(bricks: bricks, space: space)

        var all_fallen = 0
        for b in 0 ..< bricks.count-1 {
            var new_space = space
            for p in bricks[b].occupied() {
                new_space.set(p, nil)
            }
            all_fallen += just_fall(bricks: bricks, space: new_space).2
        }
        return all_fallen
    }

    func parse_input(_ lines: [String]) -> ([Brick], Space) {
        let bricks: [Brick] = lines.enumerated().map { Brick.parse($0, $1) }
        var max_x = 10, max_y = 10, max_z = 0

        for b in bricks {
            max_z = max(max_z, b.p2.z)
        }
        var space: [[[Int?]]] = Array(repeating: Array(repeating: Array(repeating: nil, count: max_x+1), count: max_y+1), count: max_z+1)

        for b in bricks {
            for p in b.occupied() {
                space.set(p, b.id)
            }
        }

        return (bricks, space)
    }
}
