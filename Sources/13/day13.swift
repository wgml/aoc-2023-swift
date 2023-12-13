import Common
import Foundation

struct Pattern {
    let rows: [[Bool]]
    let cols: [[Bool]]
}

struct Reflections {
    let horizontal: Int?
    let vertical: Int?
}

func find_reflection(_ lines: [[Bool]], skip: Int? = nil) -> Int? {
    for line in 1..<lines.count {
        if skip == line {
            continue
        }

        var found = true
        for i in 0..<min(line, lines.count - line) {
            if lines[line - i - 1] != lines[line + i] {
                found = false
                break
            }
        }
        if found {
            return line
        }
    }
    return nil
}

func find_reflections(_ pattern: Pattern) -> Reflections {
    return Reflections(horizontal: find_reflection(pattern.rows), vertical: find_reflection(pattern.cols))
}

func find_reflections_with_smudge(_ pattern: Pattern, was: Reflections) -> Reflections {
    for smudge_y in 0..<pattern.rows.count {
        for smudge_x in 0..<pattern.cols.count {
            var rows = pattern.rows
            rows[smudge_y][smudge_x] = !rows[smudge_y][smudge_x]
            if let r = find_reflection(rows, skip: was.horizontal) {
                return Reflections(horizontal: r, vertical: nil)
            }

            var cols = pattern.cols
            cols[smudge_x][smudge_y] = !cols[smudge_x][smudge_y]
            if let r = find_reflection(cols, skip: was.vertical) {
                return Reflections(horizontal: nil, vertical: r)
            }
        }
    }
    fatalError("Didn't find smudge")
}

@main
open class Day13: Common.Day<Int> {
    static func main() {
        Day13().run()
    }

    override open func part1(_ lines: [String]) -> Int {
        return parse_input(lines).map { find_reflections($0) }
            .reduce(0) { res, r -> Int in res + 100 * (r.horizontal ?? 0) + (r.vertical ?? 0) }
    }

    override open func part2(_ lines: [String]) -> Int {
        return parse_input(lines).map { find_reflections_with_smudge($0, was: find_reflections($0)) }
            .reduce(0) { res, r -> Int in res + 100 * (r.horizontal ?? 0) + (r.vertical ?? 0) }
    }

    func parse_input(_ lines: [String]) -> [Pattern] {
        var patterns: [Pattern] = []

        var i = 0
        var chunked: [[[Character]]] = []
        while i < lines.count {
            var chunk: [[Character]] = []
            while i < lines.count && lines[i] != "" {
                chunk.append(Array(lines[i]))
                i += 1
            }
            chunked.append(chunk)
            i += 1
        }

        for chunk in chunked {
            let width = chunk.first!.count
            let height = chunk.count

            var rows: [[Bool]] = []
            var cols: [[Bool]] = []

            for r in 0..<height {
                var row: [Bool] = []
                for c in 0..<width {
                    row.append(chunk[r][c] == "#")
                }
                rows.append(row)
            }

            for c in 0..<width {
                var col: [Bool] = []
                for r in 0..<height {
                    col.append(chunk[r][c] == "#")
                }
                cols.append(col)
            }
            patterns.append(Pattern(rows: rows, cols: cols))
        }

        return patterns
    }
}
