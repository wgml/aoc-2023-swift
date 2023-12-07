import Foundation

struct Hand {
    static let FIVE_OAC = 6
    static let FOUR_OAC = 5
    static let FULL_HOUSE = 4
    static let THREE_OAC = 3
    static let TWO_PAIR = 2
    static let ONE_PAIR = 1
    static let HIGH_CARD = 0

    static let ranks: [Character: Int] = [
        "2": 0,
        "3": 1,
        "4": 2,
        "5": 3,
        "6": 4,
        "7": 5,
        "8": 6,
        "9": 7,
        "T": 8,
        "J": 9,
        "Q": 10,
        "K": 11,
        "A": 12
    ]

    let type: Int
    let type_with_jokers: Int
    let cards: String
    let card_ranks: [Int]
    let bid: Int
}

func sort_by_rank(_ lhs: Hand, _ rhs: Hand) -> Bool {
    if lhs.type != rhs.type {
        return lhs.type < rhs.type
    }

    for (l, r) in zip(lhs.card_ranks, rhs.card_ranks) {
        if l != r {
            return l < r
        }
    }

    return false
}

func sort_by_rank_with_jokers(_ lhs: Hand, _ rhs: Hand) -> Bool {
    if lhs.type_with_jokers != rhs.type_with_jokers {
        return lhs.type_with_jokers < rhs.type_with_jokers
    }

    let joker_rank = Hand.ranks["J"]
    for (l, r) in zip(lhs.card_ranks, rhs.card_ranks) {
        if l != r {
            if l == joker_rank {
                return true
            } else if r == joker_rank {
                return false
            } else {
                return l < r
            }
        }
    }

    return false
}

func hand_type(_ cards: String.SubSequence) -> Int {
    var counts: [Character: Int] = [:]
    for c in cards {
        if counts[c] == nil {
            counts[c] = 0
        }
        counts[c]! += 1
    }

    if counts.count <= 1 {
        return Hand.FIVE_OAC
    }
    if counts.count == 2 {
        if counts.values.sorted().first == 1 {
            return Hand.FOUR_OAC
        } else {
            return Hand.FULL_HOUSE
        }
    }
    if counts.count == 3 {
        if counts.values.sorted()[1] != 2 {
            return Hand.THREE_OAC
        } else {
            return Hand.TWO_PAIR
        }
    }
    if counts.count == 4 {
        return Hand.ONE_PAIR
    }
    return Hand.HIGH_CARD
}

func card_ranks(_ cards: String.SubSequence) -> [Int] {
    return cards.map { (c: Character) -> Int in Hand.ranks[c]! }
}

func rank_hands(hands: [Hand], sorted_by: (Hand, Hand) -> Bool) -> Int {
    var result = 0
    for (rank, hand) in hands.sorted(by: sorted_by).enumerated() {
        result += (rank + 1) * hand.bid
    }

    return result
}

enum Day07 {
    static func part1(_ lines: [String]) -> Int {
        return rank_hands(hands:parse_input(lines), sorted_by: sort_by_rank)
    }

    static func part2(_ lines: [String]) -> Int {
        return rank_hands(hands:parse_input(lines), sorted_by: sort_by_rank_with_jokers)
    }

    static func parse_input(_ lines: [String]) -> [Hand] {
        var hands: [Hand] = []
        for line in lines {
            let parts = line.split(separator: " ")
            let cards = parts[0]
            let type = hand_type(cards)
            let type_with_jokers = hand_type(cards.filter { c in c != "J" })

            hands.append(Hand(type: type, type_with_jokers: type_with_jokers, cards: String(cards), card_ranks: card_ranks(cards), bid: Int(parts[1])!))
        }
        return hands
    }
}
