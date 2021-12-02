import Foundation

func main() throws {
    let input: [String] = try readInput()

    let instructions = buildInstructions(using: input)

    let submarine = Submarine()
    submarine.executeMovementInstructions(instructions)

    print(submarine.positionProduct)
}

private func buildInstructions(using input: [String]) -> [Submarine.MovementInstruction] {
    input.map({
        let split = $0.split(separator: " ")
        return Submarine.MovementInstruction(direction: .init(rawValue: String(split[0]))!, amount: Int(split[1])!)
    })
}

class Submarine {
    private var position: Position = Position(x: 0, y: 0)
    private var aim: Int = 0

    var positionProduct: Int { position.x * position.y }

    func executeMovementInstructions(_ instructions: [MovementInstruction]) {
        instructions.forEach(executeMovementInstruction)
    }

    private func executeMovementInstruction(_ instruction: MovementInstruction) {
        aim += (instruction.direction.aimModifier * instruction.amount)
        if instruction.direction == .forward { adjustPosition(by: instruction.amount) }
    }

    private func adjustPosition(by amount: Int) {
        position = Position(x: position.x + amount, y: position.y + (aim * amount))
    }

    struct MovementInstruction {
        let direction: Direction
        let amount: Int

        enum Direction: String {
            case down
            case forward
            case up

            var aimModifier: Int {
                switch self {
                    case .down:    return 1
                    case .forward: return 0
                    case .up:      return -1
                }
            }
        }
    }

    struct Position {
        let x: Int
        let y: Int
    }
}

try main()
