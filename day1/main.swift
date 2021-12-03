import Foundation

func main() throws {
    let input: [Int] = try readInput()

    let increases = (0..<(input.count - 2)).reduce(0, { (currentIncreases, index) in
        guard index > 0 else { return currentIncreases }
        let previousWindowSum = input[index-1...index+1].sum()
        let windowSum = input[index...index+2].sum()
        return windowSum > previousWindowSum ? currentIncreases + 1 : currentIncreases
    })

    print(increases)
}

try main()
