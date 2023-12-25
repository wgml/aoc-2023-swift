import Common
import Foundation

struct Vec3: Equatable {
    let x, y, z: Double

    func dot_product(_ b: Vec3) -> Double {
        return self.x * b.x + self.y * b.y + self.z * b.z
    }

    func cross_product(_ b: Vec3) -> Vec3 {
        return Vec3(x: self.y * b.z - self.z * b.y, y: self.z * b.x - self.x * b.z, z: self.x * b.y - self.y * b.x)
    }

    func independent(_ b: Vec3) -> Bool {
        let cp = self.cross_product(b)
        return cp.x != 0 || cp.y != 0 || cp.z != 0
    }
}

func - (a: Vec3, b: Vec3) -> Vec3 {
    return Vec3(x: a.x - b.x, y: a.y - b.y, z: a.z - b.z)
}

struct Hailstone: Equatable {
    let pos: Vec3
    let vel: Vec3
}

func intersects_in_area(_ a: Hailstone, _ b: Hailstone, minimum: Double, maximum: Double) -> Bool {
    let a_a = a.vel.y / a.vel.x
    let a_b = b.vel.y / b.vel.x
    if a_a == a_b {
        return false
    }
    let c_a = a.pos.y - a_a * a.pos.x
    let c_b = b.pos.y - a_b * b.pos.x
    let x = (c_b - c_a) / (a_a - a_b)
    let y = x * a_a + c_a

    if x < a.pos.x && a.vel.x > 0 {
        return false
    }
    if x > a.pos.x && a.vel.x < 0 {
        return false
    }
    if x < b.pos.x && b.vel.x > 0 {
        return false
    }
    if x > b.pos.x && b.vel.x < 0 {
        return false
    }
    return minimum <= x && x <= maximum && minimum <= y && y <= maximum
}

func independent_stones(_ stones: [Hailstone]) -> (Hailstone, Hailstone, Hailstone) {
    let s1 = stones.first!
    var s2, s3: Hailstone?
    var i = 0
    while i < stones.count {
        i += 1
        let c = stones[i]
        if s1.vel.independent(c.vel) {
            s2 = c
            break
        }
    }
    while i < stones.count {
        i += 1
        let c = stones[i]
        if s1.vel.independent(c.vel), s2!.vel.independent(c.vel) {
            s3 = c
            break
        }
    }

    return (s1, s2!, s3!)
}

func plane(_ s1: Hailstone, _ s2: Hailstone) -> (Vec3, Double) {
    let p = s1.pos - s2.pos
    let v = s1.vel - s2.vel
    let vv = s1.vel.cross_product(s2.vel)
    return (p.cross_product(v), p.dot_product(vv))
}

func lin(_ r: Double, _ a: Vec3, _ s: Double, _ b: Vec3, _ t: Double, _ c: Vec3) -> Vec3 {
    let x = r * a.x + s * b.x + t * c.x
    let y = r * a.y + s * b.y + t * c.y
    let z = r * a.z + s * b.z + t * c.z
    return Vec3(x: x, y: y, z: z)
}

func throw_rock(_ s1: Hailstone, _ s2: Hailstone, _ s3: Hailstone) -> Vec3 {
    let (a, A) = plane(s1, s2)
    let (b, B) = plane(s1, s3)
    let (c, C) = plane(s2, s3)

    let w_d = lin(A, b.cross_product(c), B, c.cross_product(a), C, a.cross_product(b))
    let t = a.dot_product(b.cross_product(c))
    let w = Vec3(x: (w_d.x / t).rounded(), y: (w_d.y / t).rounded(), z: (w_d.z / t).rounded())
    let w1 = s1.vel - w
    let w2 = s2.vel - w
    let ww = w1.cross_product(w2)

    let E = ww.dot_product(s2.pos.cross_product(w2))
    let F = ww.dot_product(s1.pos.cross_product(w1))
    let G = s1.pos.dot_product(ww)
    let S = ww.dot_product(ww)

    let rock = lin(E, w1, -F, w2, G, ww)
    return Vec3(x: rock.x / S, y: rock.y / S, z: rock.z / S)
}

@main
open class Day24: Common.Day<Int> {
    static func main() {
        Day24().run()
    }

    override open func part1(_ lines: [String]) -> Int {
        let stones = self.parse_input(lines)
        var intersections = 0
        for (i, s1) in stones.enumerated() {
            for s2 in stones[i + 1 ..< stones.count] {
                if intersects_in_area(s1, s2, minimum: 200000000000000, maximum: 400000000000000) {
                    intersections += 1
                }
            }
        }

        return intersections
    }

    override open func part2(_ lines: [String]) -> Int {
        let stones = self.parse_input(lines)
        let (s1, s2, s3) = independent_stones(stones)
        let rock = throw_rock(s1, s2, s3)
        return Int(rock.x + rock.y + rock.z)
    }

    func parse_input(_ lines: [String]) -> [Hailstone] {
        var stones: [Hailstone] = []
        for line in lines {
            let pos_vel = line.split(separator: " @ ")
            let pos = pos_vel[0].split(separator: ", ").map { Double($0.trimmingCharacters(in: [" "]))! }
            let vel = pos_vel[1].split(separator: ", ").map { Double($0.trimmingCharacters(in: [" "]))! }
            stones.append(Hailstone(pos: Vec3(x: pos[0], y: pos[1], z: pos[2]),
                                    vel: Vec3(x: vel[0], y: vel[1], z: vel[2])))
        }
        return stones
    }
}
