import Foundation

func main() throws {
    let isTestMode = CommandLine.arguments.contains("test")
    let input: [String] = try readInput(fromTestFile: isTestMode)

    var insertionRules: [String: String] = [:]
    
    for line in (input[2..<input.count]) {
        let split = line.components(separatedBy: " -> ")
        insertionRules[split[0]] = split[1]
    }
    print(insertionRules)

    var pairs: [String] = []
    for i in 0..<input[0].count - 1 {
        pairs.append(input[0][i] + input[0][i+1])
    }

    typealias Memo = [String: String]
    func getExtension(_ input: String, count: Int, memo: inout Memo) -> String {
        print(count)
        assert(input.count == 2, "Incorrect input length, must be 2")

        if let memoResult = memo[input + "\(count)"] {
            return memoResult
        }

        guard let substitutionValue = insertionRules[input] else {
            return input
        }

        if count == 0 {
            return input
        }

        if count == 1 {
            return input[0] + substitutionValue + input[1]
        }

        var result = String(input[0])

        let pairs = [input[0] + substitutionValue, substitutionValue + input[1]]
        let pairOneExt = getExtension(pairs[0], count: count - 1, memo: &memo)
        let pairTwoExt = getExtension(pairs[1], count: count - 1, memo: &memo)
        
        result += pairOneExt[1..<pairOneExt.count]
        result += pairTwoExt[1..<pairTwoExt.count]

        memo[input + "\(count)"] = result
        return result
    }

    let ticks = 40

    var finalPolymer: String = ""
    var memo: Memo = [:]
    for i in 0..<pairs.count {
        let pair = pairs[i]
        var ext = getExtension(pair, count: ticks, memo: &memo)
        if i != 0 { ext.removeFirst() }
        finalPolymer += ext
        print(finalPolymer)
    }

    // print(finalPolymer)

    // print(totalPolymer)

    var charCounts: [Character: Int] = [:]
    for c in finalPolymer {
        charCounts[c] = (charCounts[c] ?? 0) + 1
    }

    let mostCommon = charCounts.values.max()!
    let leastCommon = charCounts.values.min()!
    print(mostCommon - leastCommon)
}



try main()
