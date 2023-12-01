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
    }

    func input() -> [String] {
        var input: [String] = []
        while let line = readLine() {
            input.append(line)
        }
        return input
    }
}
