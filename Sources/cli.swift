import ArgumentParser

@main
struct AdventOfCode: ParsableCommand {
    @Option(help: "Day to run")
    public var day: Int

    public func run() throws {
        let input = input()

        if day == 1 {
            print("part1 = ", Day01.part1(input))
            print("part2 = ", Day01.part2(input))
        }
        if day == 2 {
            print("part1 = ", Day02.part1(input))
            print("part2 = ", Day02.part2(input))
        }
        
        if day == 3 {
            print("part1 = ", Day03.part1(input))
            print("part2 = ", Day03.part2(input))
        }

        if day == 4 {
            print("part1 = ", Day04.part1(input))
            print("part2 = ", Day04.part2(input))
        }
        if day == 5 {
            print("part1 = ", Day05.part1(input))
            print("part2 = ", Day05.part2(input))
        }
        
        if day == 6 {
            print("part1 = ", Day06.part1(input))
            print("part2 = ", Day06.part2(input))
        }
        
        if day == 7 {
            print("part1 = ", Day07.part1(input))
            print("part2 = ", Day07.part2(input))
        }
        
        if day == 8 {
            print("part1 = ", Day08.part1(input))
            print("part2 = ", Day08.part2(input))
        }
        
        if day == 9 {
            print("part1 = ", Day09.part1(input))
            print("part2 = ", Day09.part2(input))
        }
        
        if day == 10 {
            print("part1 = ", Day10.part1(input))
            print("part2 = ", Day10.part2(input))
        }

    }

    func input() -> [String] {
        var input: [String] = []
        while let line = readLine() {
            input.append(line)
        }
        return input
    }
}
