import Foundation

public func substr_after(str: String, c: Character) -> Substring.SubSequence {
    return str[str.index(after: str.firstIndex(of: c)!)...]
}
