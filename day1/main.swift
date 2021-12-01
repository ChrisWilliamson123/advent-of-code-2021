import Foundation

func main() throws {
    let input: [Int] = try readInput()
    
    var increases = 0
    for (index, _) in input[0..<input.count - 2].enumerated() {
        guard index > 0 else { continue }
        let previousWindowSum = input[index-1...index+1].sum()
        let windowSum = input[index...index+2].sum()
        if windowSum > previousWindowSum {
            increases += 1
        }
    }

    print(increases)
}

extension ArraySlice where Element == Int {
    func sum() -> Int {
        self.reduce(0, +)
    }
}

try main()
