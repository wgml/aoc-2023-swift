import Common

struct Game {
    struct Round {
        var red: Int = 0
        var green: Int = 0
        var blue: Int = 0
    }

    var rounds: [Round] = []
}

func parseInput(_ lines: [String]) -> [Game] {
    var games: [Game] = []
    
    for line in lines {
        var game = Game()
        
        let rounds = line.split(separator: ":").last!
        for r in rounds.split(separator: ";") {
            var round = Game.Round()
            for c in r.split(separator: ",") {
                let parts = c.split(separator: " ")
                let count = parts[0]
                let color = parts[1]
                if color == "red" {
                    round.red = Int(count)!
                } else if color == "green" {
                    round.green = Int(count)!
                } else {
                    round.blue = Int(count)!
                }
            }
            game.rounds.append(round)
        }
        games.append(game)
    }
    
    return games
}

@main
open class Day02: Common.Day<Int> {
    static func main() {
        Day02().run()
    }

    override open func part1(_ lines: [String]) -> Int {
        var result = 0
        
        for (i, game) in parseInput(lines).enumerated() {
            var valid = true
            for round in game.rounds {
                if round.red > 12 || round.green > 13 || round.blue > 14 {
                    valid = false
                    break
                }
            }
            if valid {
                result += i + 1
            }
        }
        
        return result
    }

    override open func part2(_ lines: [String]) -> Int {
        var result = 0
        
        for game in parseInput(lines) {
            var reds = 0
            var greens = 0
            var blues = 0
            
            for round in game.rounds {
                reds = max(reds, round.red)
                greens = max(greens, round.green)
                blues = max(blues, round.blue)
            }
            result += reds * greens * blues
        }
        
        return result
    }
}
