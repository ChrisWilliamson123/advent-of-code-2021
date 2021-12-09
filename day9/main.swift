import Foundation

func main() throws {
    let isTestMode = CommandLine.arguments.contains("test")
    let input: [String] = try readInput(fromTestFile: isTestMode)

    let heightMap = HeightMap(input)

    let lowPoints = heightMap.getLowPoints()
    let riskLevels = lowPoints.map({ heightMap.getRiskLevel(for: $0) })
    print("Part 1: \(riskLevels.sum())")

    let basinSizes: [Int] = lowPoints.map({ heightMap.getBasinCoords(startingAt: $0).count })
    let sorted: [Int] = basinSizes.sorted()
    print("Part 2: \(sorted[sorted.count-3..<sorted.count].reduce(1, *))")
}

struct HeightMap {
    let map: [[Int]]

    init(_ input: [String]) {
        map = input.map({ inputString in [Character](inputString).map({ character in Int(character)! }) })
    }

    func getBasinCoords(startingAt coordinate: Coordinate) -> Set<Coordinate> {
        var explored: Set<Coordinate> = []

        func procedure(_ coord: Coordinate) {
            explored.insert(coord)

            let validAxialEdges = self.getAdjacents(for: coord).filter({ ($0.x == coord.x || $0.y == coord.y) && self.getHeight(for: $0) != 9 })

            for edge in validAxialEdges where !explored.contains(edge) {
                procedure(edge)
            }
        }

        procedure(coordinate)

        return explored
    }

    func getLowPoints() -> [Coordinate] {
        var lowPoints: [Coordinate] = []
        for y in 0..<map.count {
            for x in 0..<map[y].count {
                let coordinate = Coordinate(x: x, y: y)
                if isLowPoint(coordinate) {
                    lowPoints.append(coordinate)
                }
            }
        }

        return lowPoints
    }

    func getRiskLevel(for coordinate: Coordinate) -> Int {
        getHeight(for: coordinate) + 1
    }

    private func isLowPoint(_ coordinate: Coordinate) -> Bool  {
        let adjacents = getAdjacents(for: coordinate)
        let adjacentValues = adjacents.map({ getHeight(for: $0) })
        let coordinateValue = getHeight(for: coordinate)

        for av in adjacentValues {
            if av <= coordinateValue {
                return false
            }
        }

        return true
    }

    private func getAdjacents(for origin: Coordinate) -> [Coordinate] {
        origin.adjacents.filter({ adjacentCoord in
            (adjacentCoord.x >= 0 && adjacentCoord.x < map[0].count) && (adjacentCoord.y >= 0 && adjacentCoord.y < map.count)
        })
    }

    private func getHeight(for coordinate: Coordinate) -> Int {
        map[coordinate.y][coordinate.x]
    }
}

struct Coordinate: Hashable {
    let x: Int
    let y: Int

    var adjacents: [Coordinate] {
        var adjacents: [Coordinate] = []
        for x in x-1...x+1 {
            for y in y-1...y+1  {
                if x == self.x && y == self.y { continue }
                adjacents.append(Coordinate(x: x, y: y))
            }
        }
        return adjacents
    }
}

try main()
