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
    }

    func input() -> [String] {
        var input: [String] = []
        while let line = readLine() {
            input.append(line)
        }
        return input
    }
}
