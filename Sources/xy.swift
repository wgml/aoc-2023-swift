import Foundation

struct XY: Hashable {
    var x: Int
    var y: Int
    
    static func == (lhs: XY, rhs: XY) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

func += (xy: inout XY, offset: XY) {
    xy.x += offset.x
    xy.y += offset.y
}

func -= (xy: inout XY, offset: XY) {
    xy.x -= offset.x
    xy.y -= offset.y
}

func + (xy: XY, offset: XY) -> XY {
    return XY (x: xy.x + offset.x, y: xy.y + offset.y)
}

func - (xy: XY, offset: XY) -> XY {
    return XY (x: xy.x - offset.x, y: xy.y - offset.y)
}
