import Foundation

func main() throws {
    let isTestMode = CommandLine.arguments.contains("test")
    let input: [String] = try readInput(fromTestFile: isTestMode)

    var insertionRules: [String: Character] = [:]
    
    for line in (input[2..<input.count]) {
        let split = line.components(separatedBy: " -> ")
        insertionRules[split[0]] = split[1][0]
    }

    var pairs: [String] = []
    for i in 0..<input[0].count - 1 {
        pairs.append(input[0][i] + input[0][i+1])
    }

    typealias Memo = [String: [Character: Int]]
    func getExtension(_ input: String, count: Int, memo: inout Memo) -> [Character: Int] {
        assert(input.count == 2, "Incorrect input length, must be 2")

        if let memoResult = memo[input + "\(count)"] { return memoResult }

        guard let substitutionValue = insertionRules[input], count > 0 else { return input.reduce(into: [Character: Int](), { $0[$1] = ($0[$1] ?? 0) + 1 }) }

        var result: [Character: Int] = [input[0]: 1]
        let pairs = [String([input[0], substitutionValue]), String([substitutionValue, input[1]])]
        var pairOneExt = getExtension(pairs[0], count: count - 1, memo: &memo)
        var pairTwoExt = getExtension(pairs[1], count: count - 1, memo: &memo)
        
        pairOneExt[pairs[0][0]]! -= 1
        for (key, value) in pairOneExt {
            result[key] = (result[key] ?? 0) + value
        }

        pairTwoExt[pairs[1][0]]! -= 1
        for (key, value) in pairTwoExt {
            result[key] = (result[key] ?? 0) + value
        }

        memo[input + "\(count)"] = result
        return result
    }

    var memo: Memo = [:]

    for tickAmount in [("Part 1:", 10), ("Part 2:", 40)] {
        var counts: [Character: Int] = [:]
        for i in 0..<pairs.count {
            let pair = pairs[i]
            let ext = getExtension(pair, count: tickAmount.1, memo: &memo)

            if i != 0 {
                counts[pair[0]]! -= 1
            }

            for (key, value) in ext {
                counts[key] = (counts[key] ?? 0) + value
            }
        }

        let mostCommon = counts.values.max()!
        let leastCommon = counts.values.min()!
        print(tickAmount.0, mostCommon - leastCommon)
    }
}



try main()
