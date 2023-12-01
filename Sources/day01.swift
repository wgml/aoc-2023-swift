
func firstDigit(_ str: String) -> Int? {
    for c in str {
        if let i = c.wholeNumberValue {
            return i
        }
    }
    return Optional.none
}

func isDigit(_ str: String, _ i: String.Index) -> Int? {
    return str[i].wholeNumberValue
}

let digits = ["zero": 0, "one": 1, "two": 2, "three": 3, "four": 4, "five": 5, "six": 6, "seven": 7, "eight": 8, "nine": 9]

func spellsDigit(_ str: String, _ i: String.Index) -> String? {
    for d in digits.keys {
        if str[i...].hasPrefix(d) {
            return d
        }
    }

    return Optional.none
}

func identifyDigits(_ str: String) -> [Int] {
    var result: [Int] = []
    for i in str.indices {
        if let digit = isDigit(str, i) {
            result.append(digit)
        }
        if let word = spellsDigit(str, i) {
            result.append(digits[word]!)
        }
    }
    return result
}

enum Day01 {
    static func part1(_ lines: [String]) -> Int {
        var sum = 0
        for line in lines {
            let first = firstDigit(line)!
            let second = firstDigit(String(line.reversed()))!
            sum += 10 * first + second
        }
        return sum
    }

    static func part2(_ lines: [String]) -> Int {
        var sum = 0
        for line in lines {
            let digits = identifyDigits(line)
            sum += digits.first! * 10 + digits.last!
        }
        return sum
    }
}
