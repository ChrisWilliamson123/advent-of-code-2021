import Foundation

// READING INPUT
func readInput<T: StringInitialisable>(fromTestFile: Bool, separator: String = "\n") throws -> [T] {
    let inputPath = "./\(fromTestFile ? "test_" : "")input.txt"

    do {
        let contents = try String(contentsOfFile: inputPath, encoding: .utf8)
        return Array(contents.components(separatedBy: separator)).map({ T(String($0))! })
    }
    catch let error {
        print("Input parsing failed: \(error)")
        throw error
    }
}

protocol StringInitialisable {
    init?(_ string: String)
}

extension Int: StringInitialisable {}
extension Double: StringInitialisable {}
extension String: StringInitialisable {}

// ARRAY EXTENSIONS
extension ArraySlice where Element == Int {
    func sum() -> Int {
        self.reduce(0, +)
    }

    func multiply() -> Int {
        self.reduce(1, *)
    }
}

extension Array where Element == Int {
    func sum() -> Int {
        self.reduce(0, +)
    }

    func multiply() -> Int {
        self.reduce(1, *)
    }
}

extension Array where Element: Equatable {
    func combinations(count: Int) -> [[Element]] {
        if count == 0 { return [[]] }

        if count == 1 { return self.map({ [$0] }) }

        let previousCombinations = combinations(count: count - 1)

        var combinations: [[Element]] = []

        for i in (0..<count) {
            for j in (0..<previousCombinations.count) where !previousCombinations[j].contains(self[i]) {
                combinations.append(previousCombinations[j] + [self[i]])
            }
        }

        return combinations
    }
}

extension Array where Element: Hashable {
    var counts: [Element: Int] {
        reduce(into: [:], { $0[$1] = ($0[$1] ?? 0) + 1 })
    }
}

// INT EXTENSIONS
extension Int {
    init?(_ char: Character) {
        self.init(String(char))
    }
}

extension UInt16 {
    init?(_ char: Character) {
        self.init(String(char))
    }
}

// STRING EXTENSIONS
extension String {

    var length: Int {
        return count
    }

    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }

    subscript (i: Int) -> Character {
        return [Character](self[i ..< i + 1])[0]
    }

    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }

    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }

    var characterCounts: [Character: Int] {
        reduce(into: [:], { $0[$1] = ($0[$1] ?? 0) + 1 })
    }
}

struct Regex {
    private let regex: NSRegularExpression

    init(_ regex: String) {
        self.regex = try! NSRegularExpression(pattern: regex)
    }

    func doesMatch(_ text: String) -> Bool {
        let textRange = NSRange(text.startIndex..., in: text)
        return regex.firstMatch(in: text, options: [], range: textRange) != nil
    }

    func getMatches(in text: String, includeFullLengthMatch: Bool = false) -> [String] {
        let textRange = NSRange(text.startIndex..., in: text)

        let matches = regex.matches(in: text, range: textRange)
        guard let match = matches.first else { return [] }

        return (0..<match.numberOfRanges).compactMap({
            let matchRange = match.range(at: $0)

            if matchRange == textRange, !includeFullLengthMatch { return nil }

            guard let substringRange = Range(matchRange, in: text) else { return nil }
            return String(text[substringRange])
        })
    }
}

// Coordinate
struct Coordinate: Hashable {
    let x: Int
    let y: Int

    typealias FoldLine = (axis: Axis, location: Int)

    enum Axis: String {
        case y
        case x
    }

    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }

    var adjacents: [Coordinate] {
        var adjacents: [Coordinate] = []
        for x in x-1...x+1 {
            for y in y-1...y+1  {
                if x == self.x && y == self.y { continue }
                adjacents.append(Coordinate(x, y))
            }
        }
        return adjacents
    }

    func getAdjacents(in grid: [[Any]]) -> [Coordinate] {
        var adjacents: [Coordinate] = []
        for x in x-1...x+1 where x >= 0 && x < grid[0].count {
            for y in y-1...y+1 where y >= 0 && y < grid.count {
                if x == self.x && y == self.y { continue }
                adjacents.append(Coordinate(x, y))
            }
        }

        return adjacents
    }

    func getAxialAdjacents(in grid: [[Any]]) -> [Coordinate] {
        [Coordinate(x-1, y), Coordinate(x+1, y), Coordinate(x, y-1), Coordinate(x, y+1)]
    }

    func translate(along foldLine: FoldLine) -> Coordinate {
        let currentValue = foldLine.axis == .y ? y : x
        let difference = (currentValue - foldLine.location) * 2
        let newValue = currentValue - difference

        return Coordinate(foldLine.axis == .y ? x : newValue, foldLine.axis == .y ? newValue : y)
    }
}