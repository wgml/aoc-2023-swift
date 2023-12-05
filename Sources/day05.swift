import Foundation

struct Almanac {
    struct Stage {
        struct Rule {
            let from: Int
            let to: Int
            let length: Int
        }
        
        let rules: [Rule]
    }
    
    let seeds: [Int]
    let stages: [Stage]
}

func find_mapping(_ v: Int, _ rules: [Almanac.Stage.Rule]) -> (Int?, Int?) {
    for rule in rules {
        if rule.from <= v, v < (rule.from + rule.length) {
            return (rule.to + (v - rule.from), rule.length - (v - rule.from))
        }
    }
    var to_skip: Int?
    
    for rule in rules {
        if rule.from > v {
            let distance = rule.from - v
            to_skip = min(distance, to_skip ?? distance)
        }
    }
    return (Optional.none, to_skip)
}

func map_seeds(_ almanac: Almanac) -> Int {
    var result: Int?

    for seed in almanac.seeds {
        var v = seed
        for stage in almanac.stages {
            v = find_mapping(v, stage.rules).0 ?? v
        }
        
        result = min(v, result ?? v)
    }
    return result!
}

func map_seed_ranges(_ almanac: Almanac) -> Int {
    var result: Int?
        
    for i in 0 ..< almanac.seeds.count / 2 {
        let from = almanac.seeds[i * 2]
        let count = almanac.seeds[i * 2 + 1]
        
        var seed = from
        while seed < from + count {
            var v = seed
            var to_skip: Int?
            for stage in almanac.stages {
                let (res, skip) = find_mapping(v, stage.rules)
                v = res ?? v
                if let s = skip {
                    to_skip = min(s, to_skip ?? s)
                }
            }
                        
            result = min(v, result ?? v)
            seed += to_skip ?? 1
        }
    }

    return result!
}

enum Day05 {
    static func part1(_ lines: [String]) -> Int {
        let almanac = parseInput(lines)
        return map_seeds(almanac)
    }

    static func part2(_ lines: [String]) -> Int {
        let almanac = parseInput(lines)
        return map_seed_ranges(almanac)
    }
    
    static func parseInput(_ lines: [String]) -> Almanac {
        let seeds = lines[0][(lines[0].firstIndex(of: " ")!)...].split(separator: " ").map { (s: String.SubSequence) -> Int in Int(s)! }
                 
        var stages: [Almanac.Stage] = []
        
        var i = 2
        while i < lines.count {
            i += 1 // skip description line
            
            var rules: [Almanac.Stage.Rule] = []
            while i < lines.count && lines[i] != "" {
                let parts = lines[i].split(separator: " ").map { (s: String.SubSequence) -> Int in Int(s)! }
                rules.append(Almanac.Stage.Rule(from: parts[1], to: parts[0], length: parts[2]))
                
                i += 1
            }
            
            stages.append(Almanac.Stage(rules: rules))
            i += 1
        }
        return Almanac(seeds: seeds, stages: stages)
    }
}
