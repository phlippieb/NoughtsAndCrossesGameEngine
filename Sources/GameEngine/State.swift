import ReSwift

struct AppState: StateType {
    init() {
        self.gameState = .playing(PlayingState())
    }

    var gameState: GameState
}

enum GameState {
    case playing(PlayingState)
    case finished(FinishedState)

    var playingState: PlayingState? {
        guard case .playing(let playingState) = self else { return nil }
        return playingState
    }
}

struct PlayingState {
    init() {
        self.playerTurn = .nought
        self.board = [
            .none, .none, .none,
            .none, .none, .none,
            .none, .none, .none
        ]
    }

    var playerTurn: Player

    var board: [CellValue]
}

enum Player {
    case nought, cross
    
    /// Returns the other player than the current (self).
    var other: Player {
        switch self {
            case .nought: return .cross
            case .cross: return .nought
        }
    }
}

/// A cell is either none, some(nought), or some(cross).
typealias CellValue = Player?

struct FinishedState {
    var winner: Winner
}

/// Either none (draw) or some(which player won).
typealias Winner = Player?
