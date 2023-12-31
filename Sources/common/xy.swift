import Foundation

public struct XY: Hashable {
    public var x: Int
    public var y: Int

    public static let Up = XY(x: 0, y: -1)
    public static let Down = XY(x: 0, y: 1)
    public static let Left = XY(x: -1, y: 0)
    public static let Right = XY(x: 1, y: 0)

    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }

    public static func == (lhs: XY, rhs: XY) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

public func += (xy: inout XY, offset: XY) {
    xy.x += offset.x
    xy.y += offset.y
}

public func -= (xy: inout XY, offset: XY) {
    xy.x -= offset.x
    xy.y -= offset.y
}

public func + (xy: XY, offset: XY) -> XY {
    return XY(x: xy.x + offset.x, y: xy.y + offset.y)
}

public func - (xy: XY, offset: XY) -> XY {
    return XY(x: xy.x - offset.x, y: xy.y - offset.y)
}

public func * (xy: XY, times: Int) -> XY {
    return XY(x: xy.x * times, y: xy.y * times)
}
