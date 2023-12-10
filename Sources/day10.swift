import Foundation

enum Pipes {
    static let Start: Character = "S"
    
    static let dirs: [XY] = [XY(x: -1, y: 0), XY(x: 0, y: 1), XY(x: 1, y: 0), XY(x: 0, y: -1)]
    
    static let connections: [Character: [XY]] = [
        "|": [XY(x: 0, y: -1), XY(x: 0, y: 1)],
        "-": [XY(x: -1, y: 0), XY(x: 1, y: 0)],
        "L": [XY(x: 0, y: -1), XY(x: 1, y: 0)],
        "J": [XY(x: 0, y: -1), XY(x: -1, y: 0)],
        "7": [XY(x: -1, y: 0), XY(x: 0, y: 1)],
        "F": [XY(x: 1, y: 0), XY(x: 0, y: 1)],
        ".": [],
        "S": dirs
    ]
}

typealias Map = [[Character]]

func find_start(map: Map) -> XY? {
    for (y, row) in map.enumerated() {
        for (x, c) in row.enumerated() {
            if c == Pipes.Start {
                return XY(x: x, y: y)
            }
        }
    }
    
    return nil
}

func find_start_symbol(map: Map, start: XY) -> Character? {
    var dirs: Set<XY> = []
    for dir in Pipes.dirs {
        if accepts_connection_from(map: map, pos: start + dir, from: start) {
            dirs.insert(dir)
        }
    }
    
    for (c, connections) in Pipes.connections {
        if Set(connections) == dirs {
            return c
        }
    }
    
    return nil
}

func accepts_connection_from(map: Map, pos: XY, from: XY) -> Bool {
    if pos.y < 0 || pos.y >= map.count || pos.x < 0 || pos.x >= map.first!.count {
        return false
    }
    
    for option in Pipes.connections[map[pos.y][pos.x]]! {
        if pos + option == from {
            return true
        }
    }
    return false
}

func find_start_connection(pos: XY, map: Map) -> XY? {
    for xy in Pipes.dirs {
        let candidate = pos + xy
        if accepts_connection_from(map: map, pos: candidate, from: pos) {
            return xy
        }
    }
    
    return nil
}

func get_next_dir(pos: XY, prev: XY, map: Map) -> XY {
    let symbol = map[pos.y][pos.x]
    
    let connections = Pipes.connections[symbol]!
    let used_connection = prev - pos
    assert(connections.count == 2)
    
    if connections[0] == used_connection {
        return connections[1]
    } else {
        return connections[0]
    }
}

func identify_main_loop(pipes: Map) -> (Set<XY>, (XY, Character)) {
    let start = find_start(map: pipes)!
    let start_symbol = find_start_symbol(map: pipes, start: start)
    var xy = start
    var dir = find_start_connection(pos: start, map: pipes)
    var loop: Set = [xy]
    repeat {
        let new_xy = xy + dir!
        dir = get_next_dir(pos: new_xy, prev: xy, map: pipes)
        xy = new_xy
        loop.insert(xy)
    } while (xy + dir!) != start
    
    return (loop, (start, start_symbol!))
}

enum Day10 {
    static func part1(_ lines: [String]) -> Int {
        let pipes = lines.map { line -> [Character] in Array(line) }
        let (loop, _) = identify_main_loop(pipes: pipes)
        return (loop.count + 1) / 2
    }

    static func part2(_ lines: [String]) -> Int {
        var pipes = lines.map { line -> [Character] in Array(line) }
        let height = pipes.count
        let width = pipes.first!.count
        
        let (loop, (start, symbol)) = identify_main_loop(pipes: pipes)
        pipes[start.y][start.x] = symbol
        
        var result = 0
        for y in 0..<height {
            var in_loop = false
            for x in 0..<width {
                let xy = XY(x: x, y: y)
                let s = pipes[y][x]
                if loop.contains(xy) && ["F", "|", "7"].contains(s) {
                    in_loop = !in_loop
                }
                if in_loop && !loop.contains(xy) {
                    result += 1
                }
            }
        }
        
        return result
    }
}
