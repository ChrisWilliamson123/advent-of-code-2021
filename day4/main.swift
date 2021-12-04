import Foundation

func main() throws {
    let isTestMode = CommandLine.arguments.contains("test")
    let input: [String] = try readInput(fromTestFile: isTestMode)

    let numbersToDraw: [Int] = input[0].split(separator: ",").compactMap({ Int($0) })

    let partOneBingoGame = BingoGame(numbersToDraw: numbersToDraw.reversed(), boards: buildBingoBoards(from: Array(input.suffix(from: 1))))
    partOneBingoGame.play()
    print(partOneBingoGame.finalWinningScore)

    let partTwoBingoGame = BingoGame(numbersToDraw: numbersToDraw.reversed(), boards: buildBingoBoards(from: Array(input.suffix(from: 1))))
    partTwoBingoGame.playUntilEveryoneWins()
    print(partTwoBingoGame.finalWinningScore)
}

class BingoGame {
    private var numbersToDraw: [Int]
    private let boards: [BingoBoard]
    private var winners: [BingoBoard] = []
    private var previouslyPlayedNumber = 0

    var finalWinningScore: Int { winners[winners.count - 1].calculateWinningScore(using: previouslyPlayedNumber) }

    init(numbersToDraw: [Int], boards: [BingoBoard]) {
        self.numbersToDraw = numbersToDraw
        self.boards = boards
    }

    func play() {
        while let numberToPlay = numbersToDraw.popLast(), winners.count == 0 {
            playNumber(numberToPlay)
        }
    }

    func playUntilEveryoneWins() {
        while let numberToPlay = numbersToDraw.popLast(), winners.count < boards.count {
            playNumber(numberToPlay)
        }
    }

    private func playNumber(_ numberToPlay: Int) {
        boards.forEach({ board in
            board.checkNumber(numberToPlay)
            if board.hasWon() && !boardHasFinished(board) {
                winners.append(board)
            }
        })
        previouslyPlayedNumber = numberToPlay
    }

    private func boardHasFinished(_ board: BingoBoard) -> Bool {
        winners.contains(where: { $0 === board })
    }
}

class BingoBoard {
    private var board: [[BoardPosition]]
    private var unmarkedSum: Int {
        board.flatMap({ $0 }).filter({ !$0.marked }).map({ $0.value }).sum()
    }

    init(board: [[Int]]) {
        self.board = board.map({ boardRow in
            boardRow.map({ BoardPosition(value: $0) })
        })
    }

    func checkNumber(_ number: Int) {
        for i in (0..<board.count) {
            for j in (0..<board[i].count) {
                if board[i][j].value == number {
                    board[i][j].marked = true
                }
            }
        }
    }

    func hasWon() -> Bool {
        // Check if any row has won
        for i in (0..<board.count) {
            let row = board[i]
            if row.filter({ !$0.marked }).count == 0 {
                return true
            }
        }

        // Check if any column has won
        for i in (0..<board[0].count) {
            let column = (0..<board.count).map({ board[$0][i] })
            if column.filter({ !$0.marked }).count == 0 {
                return true
            }
        }
        return false
    }

    func calculateWinningScore(using winningNumber: Int) -> Int {
        winningNumber * unmarkedSum
    }

    private struct BoardPosition {
        let value: Int
        var marked: Bool

        init(value: Int) {
            self.value = value
            self.marked = false
        }
    }
}

private func buildBingoBoards(from input: [String]) -> [BingoBoard] {
    stride(from: 0, through: input.count - 5, by: 5).map({ bingoBoardStartIndex in
        let boardNumbers = input[bingoBoardStartIndex..<bingoBoardStartIndex+5]
            .flatMap({ $0.split(separator: " ").compactMap({Int($0)}) })

        let stride = stride(from: 0, through: boardNumbers.count - 5, by: 5)
        return BingoBoard(board: stride.map({ startIndex in
            Array(boardNumbers[startIndex..<startIndex+5])
        }))
    })
}

try main()
