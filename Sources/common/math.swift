import Foundation


public func lcm(_ a: Int, _ b: Int) -> Int {
    return Int(a * b / gcd(a, b))
}

public func gcd(_ a: Int, _ b: Int) -> Int {
    if b == 0 {
        return a
    }
    return gcd(b, a % b)
}
