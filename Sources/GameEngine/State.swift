import ReSwift

public struct AppState: StateType {
    init() {
        self.gameState = .playing(PlayingState())
    }

    public var gameState: GameState
}

public enum GameState {
    case playing(PlayingState)
    case finished(FinishedState)

    var playingState: PlayingState? {
        guard case .playing(let playingState) = self else { return nil }
        return playingState
    }
}

public struct PlayingState {
    init() {
        self.playerTurn = .nought
        self.board = [
            .none, .none, .none,
            .none, .none, .none,
            .none, .none, .none
        ]
    }

    public var playerTurn: Player

    public var board: [CellValue]
}

public enum Player {
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
public typealias CellValue = Player?

public struct FinishedState {
    public var winner: Winner
}

/// Either none (draw) or some(which player won).
public typealias Winner = Player?
