import Common
import Foundation

typealias XY = Common.XY

struct Platform {
    let x, y: Int
    let area: [[Bool]]
    let rocks: [[Bool]]
}

func in_bounds(platform: Platform, rock: XY) -> Bool {
    return rock.x >= 0 && rock.x < platform.x && rock.y >= 0 && rock.y < platform.y
}

func weight(platform: Platform) -> Int {
    var weight = 0
    for y in 0 ..< platform.y {
        for x in 0 ..< platform.x {
            if platform.rocks[y][x] {
                weight += platform.area.count - y
            }
        }
    }
    return weight
}

func tilt(platform: Platform, dir: XY, xs: any Sequence<Int>, ys: any Sequence<Int>) -> Platform {
    var moved_rocks = Array(repeating: Array(repeating: false, count: platform.x), count: platform.y)

    for y in ys {
        for x in xs {
            if platform.rocks[y][x] {
                var rock = XY(x: x, y: y)
                while true {
                    let moved_rock = rock + dir
                    if in_bounds(platform: platform, rock: moved_rock) && !platform.area[moved_rock.y][moved_rock.x] && !moved_rocks[moved_rock.y][moved_rock.x] {
                        rock = moved_rock
                    } else {
                        moved_rocks[rock.y][rock.x] = true
                        break
                    }
                }
            }
        }
    }

    return Platform(x: platform.x, y: platform.y, area: platform.area, rocks: moved_rocks)
}

@main
open class Day14: Common.Day<Int> {
    static func main() {
        Day14().run()
    }

    override open func part1(_ lines: [String]) -> Int {
        var platform = parse_input(lines)
        platform = tilt(platform: platform, dir: XY(x: 0, y: -1), xs: 0 ..< platform.x, ys: 0 ..< platform.y)
        return weight(platform: platform)
    }

    override open func part2(_ lines: [String]) -> Int {
        var platform = parse_input(lines)

        var cache: [[[Bool]]: Int] = [:]

        var i = 0
        let cycles = 1000000000

        simulate: while i < cycles {
            platform = tilt(platform: platform, dir: XY(x: 0, y: -1), xs: 0 ..< platform.x, ys: 0 ..< platform.y)
            platform = tilt(platform: platform, dir: XY(x: -1, y: 0), xs: 0 ..< platform.x, ys: 0 ..< platform.y)
            platform = tilt(platform: platform, dir: XY(x: 0, y: 1), xs: 0 ..< platform.x, ys: (0 ..< platform.y).reversed())
            platform = tilt(platform: platform, dir: XY(x: 1, y: 0), xs: (0 ..< platform.x).reversed(), ys: 0 ..< platform.y)

            if let prev_i = cache[platform.rocks] {
                let c = (cycles - i) / (i - prev_i)
                i += (i - prev_i) * c
                for (p, it) in cache {
                    if it == prev_i + cycles - i - 1 {
                        platform = Platform(x: platform.x, y: platform.y, area: platform.area, rocks: p)
                        break simulate
                    }
                }
            } else {
                cache[platform.rocks] = i
            }
            i += 1
        }

        return weight(platform: platform)
    }

    func parse_input(_ lines: [String]) -> Platform {
        var area: [[Bool]] = []
        var rocks: [[Bool]] = []

        for line in lines {
            var row: [Bool] = []
            var row_rocks: [Bool] = []

            for c in line {
                row.append(c == "#")
                row_rocks.append(c == "O")
            }
            area.append(row)
            rocks.append(row_rocks)
        }

        return Platform(x: area.first!.count, y: area.count, area: area, rocks: rocks)
    }
}
