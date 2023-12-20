import Common
import Foundation

enum Signal {
    case Off, On
}

class Module {
    let destinations: [String]
    var sources: [String] = []

    init(destinations: [String]) {
        self.destinations = destinations
    }

    func receive(signal: Signal, source: String) -> Signal? { fatalError("not implemented") }
    func set_sources(sources: [String]) { self.sources = sources }
    func get_sources() -> [String] { return sources }
}

class Broadcaster: Module {
    override func receive(signal: Signal, source: String) -> Signal? { return signal }
}

class FlipFlop: Module {
    var state: Signal = .Off

    override func receive(signal: Signal, source: String) -> Signal? {
        if signal == .Off {
            state = switch state {
            case .On: .Off
            case .Off: .On
            }
            return state
        } else {
            return nil
        }
    }
}

class Conjunction: Module {
    var states: [String: Signal] = [:]

    override func set_sources(sources: [String]) {
        states = sources.reduce(into: [String: Signal]()) {
            $0[$1] = .Off
        }
    }

    override func get_sources() -> [String] {
        return states.keys.map { $0 }
    }

    override func receive(signal: Signal, source: String) -> Signal? {
        states[source] = signal

        if states.allSatisfy({ e in e.value == .On }) { return Signal.Off } else { return Signal.On }
    }
}

@main
open class Day20: Common.Day<Int> {
    static func main() {
        Day20().run()
    }

    override open func part1(_ lines: [String]) -> Int {
        let (modules, _) = parse_input(lines)

        var low_pulses = 0
        var high_pulses = 0
        for _ in 1 ... 1000 {
            var queue: [((source: String, dest: String), Signal)] = [((source: "button", dest: "broadcaster"), Signal.Off)]
            while !queue.isEmpty {
                let ((source, dest), signal) = queue.removeFirst()
                switch signal {
                case .On: high_pulses += 1
                case .Off: low_pulses += 1
                }
                if let module = modules[dest] {
                    if let res = module.receive(signal: signal, source: source) {
                        for d in module.destinations {
                            queue.append(((source: dest, dest: d), res))
                        }
                    }
                }
            }
        }
        return low_pulses * high_pulses
    }

    override open func part2(_ lines: [String]) -> Int {
        let (modules, last_module_name) = parse_input(lines)

        let last_module_sources = Set(modules[last_module_name]!.get_sources())
        var last_module_cycles: [String: Int] = [:]

        var pulses = 0
        while true {
            pulses += 1
            var queue: [((source: String, dest: String), Signal)] = [((source: "button", dest: "broadcaster"), Signal.Off)]
            while !queue.isEmpty {
                let ((source, dest), signal) = queue.removeFirst()

                if last_module_sources.contains(source) && signal == .On {
                    last_module_cycles[source] = pulses
                    if last_module_cycles.count == last_module_sources.count {
                        return last_module_cycles.values.reduce(1) { lcm($0, $1) }
                    }
                }

                if let module = modules[dest] {
                    if let res = module.receive(signal: signal, source: source) {
                        for d in module.destinations {
                            queue.append(((source: dest, dest: d), res))
                        }
                    }
                }
            }
        }
        fatalError("unreachable")
    }

    func parse_input(_ lines: [String]) -> ([String: Module], String) {
        func name(_ str: Substring.SubSequence) -> String {
            if str.first! == "b" {
                return "broadcaster"
            }
            return String(str[str.index(str.startIndex, offsetBy: 1)...])
        }

        func append_source(_ sources: [String]?, _ append: String) -> [String] {
            var new_sources = sources == nil ? [] : sources!
            new_sources.append(append)
            return new_sources
        }

        var modules: [String: Module] = [:]
        var sources: [String: [String]] = [:]
        var last_module: String?

        for line in lines {
            let split = line.split(separator: " -> ")
            let module_name = name(split.first!)
            let destinations = split.last!.split(separator: ", ").map { String($0) }
            if destinations.contains("rx") {
                last_module = module_name
            }
            switch line.first! {
            case "b":
                modules[module_name] = Broadcaster(destinations: destinations)
            case "%":
                modules[name(split.first!)] = FlipFlop(destinations: destinations)
            case "&":
                modules[name(split.first!)] = Conjunction(destinations: destinations)
            default: fatalError("Unhandled: \(line.first!)")
            }
            for d in destinations {
                sources[d] = append_source(sources[d], module_name)
            }
        }

        for (n, s) in sources {
            modules[n]?.set_sources(sources: s)
        }

        return (modules, last_module!)
    }
}
