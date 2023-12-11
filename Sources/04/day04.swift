import Common
import Foundation

struct Card {
    let winning: Set<Int>
    let mine: Set<Int>
}

@main
open class Day04: Common.Day<Int> {
    static func main() {
        Day04().run()
    }
    
    override open func part1(_ lines: [String]) -> Int {
        let cards = parseInput(lines)
        
        var result = 0
        for card in cards {
            let common = card.winning.intersection(card.mine)
            result += Int(pow(Double(2), Double(common.count - 1)))
        }
        
        return result
    }

    override open func part2(_ lines: [String]) -> Int {
        let cards = parseInput(lines)
        
        var copies = Array(repeating: 1, count: cards.count)
        for (i, card) in cards.enumerated() {
            let common = card.winning.intersection(card.mine).count
            if common == 0 {
                continue
            }
            for c in 1 ... common {
                if i + c >= copies.count {
                    break
                }
                copies[i + c] += copies[i]
            }
        }
        
        return copies.reduce(0) { (sum: Int, cur: Int) -> Int in sum + cur }
    }
    
    func parseInput(_ lines: [String]) -> [Card] {
        var cards: [Card] = []
        
        for line in lines {
            let numbers = line.split(separator: ":")[1].split(separator: "|")
            let winning = numbers[0].split(separator: " ").map { (v: Substring.SubSequence) -> Int in Int(v)! }
            let mine = numbers[1].split(separator: " ").map { (v: Substring.SubSequence) -> Int in Int(v)! }
            
            cards.append(Card(winning: Set(winning), mine: Set(mine)))
        }
        
        return cards
    }
}
