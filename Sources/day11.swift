import Foundation

func calculate_distances(map: [[Bool]], expansion_rate: Int) -> Int {
    var occupied_rows : [Bool] = Array(repeating: false, count: map.count)
    var occupied_cols : [Bool] = Array(repeating: false, count: map.first!.count)
    var galaxies : [XY] = []
    for y in 0..<map.count {
        for x in 0..<map.first!.count {
            if map[y][x] {
                occupied_rows[y] = true
                occupied_cols[x] = true
                galaxies.append(XY(x:x, y:y))
            }
        }
    }
    
    var distances = 0
    
    for (i, g1) in galaxies.enumerated() {
        for g2 in galaxies[(i + 1)...] {
            var distance = abs(g1.y - g2.y) + abs(g1.x - g2.x)

            for x in min(g1.x, g2.x) ..< max(g1.x, g2.x) {
                if !occupied_cols[x] {
                    distance += (expansion_rate - 1)
                }
            }
            
            for y in min(g1.y, g2.y) ..< max(g1.y, g2.y) {
                if !occupied_rows[y] {
                    distance += (expansion_rate - 1)
                }
            }

            distances += distance
        }
    }
    return distances
}

enum Day11 {
    static func part1(_ lines: [String]) -> Int {
        return calculate_distances(map: parse_input(lines), expansion_rate: 2)
    }
    
    static func part2(_ lines: [String]) -> Int {
        return calculate_distances(map: parse_input(lines), expansion_rate: 1_000_000)
    }


    static func parse_input(_ lines: [String]) -> [[Bool]] {
        return lines.map { l -> [Bool] in l.map { e -> Bool in e == "#" } }
    }
}
