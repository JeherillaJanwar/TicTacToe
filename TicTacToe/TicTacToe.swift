import SwiftUI

struct TicTacToe {
    enum Player: String, CustomStringConvertible {
        case x, o
        
        var opponent: Player {
            switch self {
            case .x:
                return .o
            case .o:
                return .x
            }
        }
        
        var description: String {
            rawValue.capitalized
        }
    }
    
    private(set) var grid: [Player?] = Array(repeating: nil,
                                             count: 9)
    
    private(set) var currentPlayer: Player
    private var matchingIndices: Set<Int> = []
    private var turns: Int = 0
    
    init(startingPlayer: Player) {
        currentPlayer = startingPlayer
    }
    
    var hasWinner: Bool {
        !matchingIndices.isEmpty
    }
    
    var isFirstTurn: Bool {
        turns == 0
    }
    
    var hasNotEnded: Bool {
        !hasWinner && turns != 9
    }
    
    static func index(row: Int, column: Int) -> Int {
        assert([row, column].allSatisfy {
            (0..<3).contains($0)
        })
        return 3 * row + column
    }
    
    func isMatching(at index: Int) -> Bool {
        matchingIndices.contains(index)
    }
    
    func isEmpty(at index: Int) -> Bool {
        grid[index] == nil
    }
    
    private func canPlay(at index: Int) -> Bool {
        isEmpty(at: index) && hasNotEnded
    }
    
    
    mutating func play(at index: Int) {
        assert(canPlay(at: index))
        grid[index] = currentPlayer
        for (i, j, k) in TicTacToe.pairsAdjacent(to: index) {
            guard grid[i] == grid[j] && grid[j] == grid[k] else { continue }
            for matchingIndex in [i, j, k] {
                matchingIndices.insert(matchingIndex)
            }
        }
        turns += 1
        if hasNotEnded {
            currentPlayer = currentPlayer.opponent
        }
    }
    
    private static func pairsAdjacent(to index: Int) -> [(Int, Int, Int)] {
        let (row, column) = index.quotientAndRemainder(dividingBy: 3)
        let rowStart = 3 * row
        var pairs = [(rowStart, rowStart + 1, rowStart + 2),
                     (column, column + 3, column + 6)]
        if row == column {
            pairs.append((0, 4, 8))
        }
        if row + column == 2 {
            pairs.append((2, 4, 6))
        }
        return pairs
    }
}

// MARK: - AI logic
extension TicTacToe {
    private func heuristic(index: Int) -> Int {
        assert(canPlay(at: index))
        return TicTacToe.pairsAdjacent(to: index).map { i, j, k in
            var count = (player: 1, opponent: 0)
            [i, j, k]
                .compactMap { index in
                    grid[index]
                }
                .forEach { player in
                    if player == currentPlayer {
                        count.player += 1
                    } else {
                        count.opponent += 1
                    }
                }
            switch count {
            case (3, 0):
                return 100
            case (1, 2):
                return 10
            case (2, 0):
                return 1
            default:
                return 0
            }
        }
        .reduce(0, +)
    }
    
    private var emptyIndices: [Int] {
        grid.indices.filter { isEmpty(at: $0) }
    }
    
    private mutating func minimax(index: Int,
                                  maximizer: Player,
                                  score: (maximizer: Int, minimizer: Int) = (Int.min, Int.max)) -> Int {
        play(at: index)
        defer {
            undoPlay(at: index)
        }
        guard hasNotEnded else {
            // case draw
            guard hasWinner else { return 0 }
            if currentPlayer == maximizer {
                // case win
                return 1
            } else {
                // case loss
                return -1
            }
        }
        var score = score
        for nextIndex in emptyIndices where score.maximizer < score.minimizer {
            let nextScore = minimax(index: nextIndex,
                                    maximizer: maximizer,
                                    score: score)
            if currentPlayer == maximizer {
                score.maximizer = max(score.maximizer, nextScore)
            } else {
                score.minimizer = min(score.minimizer, nextScore)
            }
        }
        return currentPlayer == maximizer ? score.maximizer : score.minimizer
    }
    
    
    private mutating func undoPlay(at index: Int) {
        assert(!isEmpty(at: index))
        if hasNotEnded {
            currentPlayer = currentPlayer.opponent
        } else {
            matchingIndices.removeAll()
        }
        turns -= 1
        grid[index] = nil
    }
    
    enum Difficulty: String, CaseIterable, Identifiable {
        case easy
        case medium
        case hard
        
        var id: Self { self }
    }
    
    mutating func bestMove(difficulty: Difficulty) -> Int? {
        guard hasNotEnded else { return nil }
        switch difficulty {
        case .easy:
            return emptyIndices.randomElement()
        case .medium:
            return emptyIndices
                .shuffled()
                .max(by: {
                    heuristic(index: $0)
                })
        case .hard:
            return emptyIndices.max(by: {
                minimax(index: $0,
                        maximizer: currentPlayer)
            })
        }
    }
}

extension Sequence {
    func max<T : Comparable>(by property: (Element) -> T) -> Element? {
        var iterator = makeIterator()
        guard let first = iterator.next() else { return nil }
        var max = (element: first, property: property(first))
        while let nextElement = iterator.next() {
            let nextProperty = property(nextElement)
            if nextProperty > max.property {
                max = (nextElement, nextProperty)
            }
        }
        return max.element
    }
}
