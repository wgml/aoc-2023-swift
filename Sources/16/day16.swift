import Common
import Foundation

enum Element {
    case Empty
    case Mirror(kind: Character)
    case Splitter(kind: Character)
}

class Contraption {
    let board: [[Element]]

    public init(board: [[Element]]) {
        self.board = board
    }

    func in_bounds(pos: XY) -> Bool {
        return pos.x >= 0 && pos.x < board[0].count && pos.y >= 0 && pos.y < board.count
    }

    func at(pos: XY) -> Element {
        return board[pos.y][pos.x]
    }

    func energize(ray: Ray) -> Int {
        var visited: [[Bool]] = Array(repeating: Array(repeating: false, count: board[0].count), count: board.count)
        var known: [[[Bool]]] = Array(repeating: Array(repeating: [false, false, false, false], count: board[0].count), count: board.count)

        var rays: [Ray] = [ray]
        while !rays.isEmpty {
            var ray = rays.removeFirst()

            ray: while in_bounds(pos: ray.pos) {
                if !in_bounds(pos: ray.pos) {
                    break
                }
                let i = ray.dir_index()
                if known[ray.pos.y][ray.pos.x][i] {
                    break
                }
                known[ray.pos.y][ray.pos.x][i] = true
                visited[ray.pos.y][ray.pos.x] = true

                switch at(pos: ray.pos) {
                case Element.Empty:
                    ray.move()
                case let Element.Mirror(kind):
                    ray.bounce(mirror: kind)
                    ray.move()
                case let Element.Splitter(kind):
                    for var r in ray.split(splitter: kind) {
                        r.move()
                        rays.append(r)
                    }
                    break ray
                }
            }
        }

        return visited.map { r in r.filter { e in e }.count }.reduce(0, +)
    }
}

struct Ray: Hashable {
    var pos: XY
    var dir: XY

    static let Upward = XY(x: 0, y: -1)
    static let Downward = XY(x: 0, y: 1)
    static let Leftward = XY(x: -1, y: 0)
    static let Rightward = XY(x: 1, y: 0)

    func dir_index() -> Int {
        return switch dir {
        case Ray.Upward: 0
        case Ray.Downward: 1
        case Ray.Leftward: 2
        case Ray.Rightward: 3
        default: fatalError("Unhandled \(dir)")
        }
    }

    mutating func move() {
        pos += dir
    }

    mutating func bounce(mirror: Character) {
        if mirror == "/" {
            dir = switch dir {
            case Ray.Upward: Ray.Rightward
            case Ray.Rightward: Ray.Upward
            case Ray.Downward: Ray.Leftward
            case Ray.Leftward: Ray.Downward
            default: fatalError("Unhandled \(dir)")
            }
        } else { // \
            dir = switch dir {
            case Ray.Upward: Ray.Leftward
            case Ray.Leftward: Ray.Upward
            case Ray.Downward: Ray.Rightward
            case Ray.Rightward: Ray.Downward
            default: fatalError("Unhandled \(dir)")
            }
        }
    }

    func split(splitter: Character) -> [Ray] {
        if dir.x == 0 && splitter == "|" || dir.y == 0 && splitter == "-" {
            return [self]
        }
        if splitter == "|" {
            return [Ray(pos: pos, dir: Ray.Upward), Ray(pos: pos, dir: Ray.Downward)]
        } else {
            return [Ray(pos: pos, dir: Ray.Leftward), Ray(pos: pos, dir: Ray.Rightward)]
        }
    }
}

@main
open class Day16: Common.Day<Int> {
    static func main() {
        Day16().run()
    }

    override open func part1(_ lines: [String]) -> Int {
        let contraption = parse_input(lines)
        return contraption.energize(ray: Ray(pos: XY(x: 0, y: 0), dir: Ray.Rightward))
    }

    override open func part2(_ lines: [String]) -> Int {
        let contraption = parse_input(lines)

        var best = 0
        for x in 0..<contraption.board[0].count {
            best = max(best, contraption.energize(ray: Ray(pos: XY(x: x, y: 0), dir: Ray.Downward)))
            best = max(best, contraption.energize(ray: Ray(pos: XY(x: x, y: contraption.board.count - 1), dir: Ray.Upward)))
        }
        for y in 0..<contraption.board.count {
            best = max(best, contraption.energize(ray: Ray(pos: XY(x: 0, y: y), dir: Ray.Rightward)))
            best = max(best, contraption.energize(ray: Ray(pos: XY(x: contraption.board[0].count - 1, y: y), dir: Ray.Leftward)))
        }
        return best
    }

    func parse_input(_ lines: [String]) -> Contraption {
        var board: [[Element]] = []
        for line in lines {
            var row: [Element] = []
            for c in line {
                let e = switch c {
                case ".": Element.Empty
                case "\\", "/": Element.Mirror(kind: c)
                case "-", "|": Element.Splitter(kind: c)
                default: fatalError("unhandled: '\(c)'")
                }
                row.append(e)
            }
            board.append(row)
        }
        return Contraption(board: board)
    }
}
