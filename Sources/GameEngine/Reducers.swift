import ReSwift

func mainReducer(action: Action, state: AppState?) -> AppState {
    var state = state ?? AppState()

    switch state.gameState {
    case .playing:
        state = playingReducer(action: action, state: state)

    case .finished:
        state = finishedReducer(action: action, state: state)
    }

    return state
}

private func playingReducer(action: Action, state: AppState) -> AppState {
    var state = state

    switch action {
    
    case let placePieceAction as PlacePieceAction:
        guard case .playing(var playingState) = state.gameState else { break }
        guard playingState.board[placePieceAction.index] == nil else { break }
        playingState.board[placePieceAction.index] = playingState.playerTurn
        playingState.playerTurn = (playingState.playerTurn.other)

        if let winner = getWinner(board: playingState.board) {
            let finishedState = FinishedState(winner: winner)
            state.gameState = .finished(finishedState)
        
        } else if playingState.board.filter({ $0 == .none }).isEmpty {
            let finishedState = FinishedState(winner: .none)
            state.gameState = .finished(finishedState)
        
        } else {
            state.gameState = .playing(playingState)
        }

    default:
        break
    }

    return state
}

private func finishedReducer(action: Action, state: AppState) -> AppState {
    var state = state

    switch action {

    case _ as RestartGameAction:
        state.gameState = .playing(PlayingState())

    default:
        break
    }

    return state
}

private func getWinner(board: [CellValue]) -> Winner? {
    let rows: [[Int]] = [[0, 1, 2], [3, 4, 5], [6, 7,8]]
    let cols: [[Int]] = [[0, 3, 6], [1, 4, 7], [2, 5, 8]]
    let diags: [[Int]] = [[0, 4, 8], [2, 4, 6]]
    for row in rows + cols + diags {
        guard board[row[0]] != nil else { continue } // Winner must be non-nil.
        if board[row[0]] == board[row[1]] && board[row[1]] == board[row[2]] {
            return board[row[0]]
        }
    }
    return nil
}
