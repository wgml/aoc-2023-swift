open class Day<T> {
    public init() {}

    public func run() {
        let input = read_input()

        print("part1 = \(part1(input))")
        print("part2 = \(part2(input))")
    }
    
    func read_input() -> [String] {
        var input: [String] = []
        while let line = readLine() {
            input.append(line)
        }
        return input
    }

    open func part1(_ lines: [String]) -> T {
        fatalError("not implemented")
    }
    
    open func part2(_ lines: [String]) -> T {
        fatalError("not implemented")
    }
}
