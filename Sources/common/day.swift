open class Day<T> {
    public init() {}

    public func run() {
        print("# \(type_name())")
        let clock = ContinuousClock()
        let input = read_input()

        let elapsed1 = clock.measure {
            print("- part1 = \(part1(input))", terminator: "")
        }
        print (" (took \(elapsed1))")
        
        let elapsed2 = clock.measure {
            print("- part2 = \(part2(input))", terminator: "")
        }
        print (" (took \(elapsed2))")
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
    
    func type_name() -> String {
        let name = String(describing: type(of: self))
        return name
    }
}
