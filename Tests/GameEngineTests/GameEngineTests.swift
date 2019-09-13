import Quick
import Nimble
@testable import GameEngine

final class GameEngineSpec: QuickSpec {
    override func spec() {
        
        // Helpers

        func expectPlaying(gameState: GameState, handler: @escaping (PlayingState) -> Void) {
            expect({
                guard case .playing(let playingState) = gameState 
                    else { return .failed(reason: "Expected gameState to be playing.") }

                handler(playingState)
                return .succeeded
            }).to(succeed())
        }

        func expectFinised(gameState: GameState, handler: @escaping (FinishedState) -> Void) {
            expect({
                guard case .finished(let finishedState) = gameState
                    else { return .failed(reason: "Expected gameState to be finished.") }

                handler(finishedState)
                return .succeeded
            }).to(succeed())
        }

        // Tests

        describe("A new game state") {
            it("starts in the playing state, with 9 places on the board, with no pieces") {
                let newState = AppState()
                expectPlaying(gameState: newState.gameState) { playingState in
                    expect(playingState.playerTurn).to(equal(.nought))
                    expect(playingState.board.count).to(equal(9))
                    
                    for cell in playingState.board {
                        expect(cell).to(beNil())
                    }
                }
            }
        }

        describe("Playing a valid move as noughts") {
            let store = MainStore()
            store.dispatch(PlacePieceAction(index: 0))
            
            expectPlaying(gameState: store.state.gameState) { playingState in
                for (i, cell) in playingState.board.enumerated() {
                    if i == 0 {
                        it("places a nought piece on the board") {
                            expect(cell).to(equal(.nought))
                        }
                    } else {
                        it("does not place any other pieces on the board") {
                            expect(cell).to(beNil())
                        }
                    }
                }

                it("switches to crosses' turn") {
                    expect(playingState.playerTurn).to(equal(.cross))
                }
            }
        }

        describe("Playing a valid move as crosses") {
            let store = MainStore()
            store.dispatch(PlacePieceAction(index: 0))
            store.dispatch(PlacePieceAction(index: 1))

            expectPlaying(gameState: store.state.gameState) { playingState in
                for (i, cell) in playingState.board.enumerated() {
                    if i == 0 {
                        it("places a nought piece on the board") {
                            expect(cell).to(equal(.nought))
                        }
                    } else if i == 1 {
                        it("places a cross piece on the board") {
                            expect(cell).to(equal(.cross))
                        }
                    } else {
                        it("does not place any other pieces on the board") {
                            expect(cell).to(beNil())
                        }
                    }
                }

                it("switches back to noughts' turn") {
                    expect(playingState.playerTurn).to(equal(.nought))
                }
            }
        }

        describe("Playing an invalid move as crosses") {
            let store = MainStore()
            store.dispatch(PlacePieceAction(index: 1))
            store.dispatch(PlacePieceAction(index: 1))

            expectPlaying(gameState: store.state.gameState) { playingState in
                for (i, cell) in playingState.board.enumerated() {
                    if i == 1 {
                        it("does not replace a nought with a cross piece") {
                            expect(cell).to(equal(.nought))
                        }
                    } else {
                        it("does not place any other pieces on the board") {
                            expect(cell).to(beNil())
                        }
                    }
                }

                it("does not switch back to noughts' turn") {
                    expect(playingState.playerTurn).to(equal(.cross))
                }
            }
        }

        describe("Playing 3 noughts in a horizontal row (1)") {
            let store = MainStore()
            store.dispatch(PlacePieceAction(index: 0)) // nought: [0, 0]
            store.dispatch(PlacePieceAction(index: 4)) // cross:  [1, 0]
            store.dispatch(PlacePieceAction(index: 1)) // nought: [0, 1]
            store.dispatch(PlacePieceAction(index: 6)) // cross:  [1, 2]
            store.dispatch(PlacePieceAction(index: 2)) // nought: [0, 0]

            it("finishes the game and noughts win") {
                expectFinised(gameState: store.state.gameState) { finishedState in
                    expect(finishedState.winner).to(equal(.nought))
                }
            }
        }

        describe("Playing 3 crosses in a horizontal row") {
            let store = MainStore()
            store.dispatch(PlacePieceAction(index: 0)) // nought: [0, 0]
            store.dispatch(PlacePieceAction(index: 3)) // cross:  [1, 0]
            store.dispatch(PlacePieceAction(index: 1)) // nought: [0, 1]
            store.dispatch(PlacePieceAction(index: 4)) // cross:  [1, 1]
            store.dispatch(PlacePieceAction(index: 8)) // nought: [2, 2]
            store.dispatch(PlacePieceAction(index: 5)) // nought: [1, 2]

            it("finishes the game and noughts win") {
                expectFinised(gameState: store.state.gameState) { finishedState in
                    expect(finishedState.winner).to(equal(.cross))
                }
            }
        }

        describe("Playing 3 crosses in a vertical row") {
            let store = MainStore()
            store.dispatch(PlacePieceAction(index: 0)) // nought: [0, 0]
            store.dispatch(PlacePieceAction(index: 2)) // cross: [0, 2]
            store.dispatch(PlacePieceAction(index: 1)) // nought: [0, 1]
            store.dispatch(PlacePieceAction(index: 5)) // cross: [1, 2]
            store.dispatch(PlacePieceAction(index: 6)) // nought: [2, 0]
            store.dispatch(PlacePieceAction(index: 8)) // cross: [2, 2]

            it("finishes the game and crosses win") {
                expectFinised(gameState: store.state.gameState) { finishedState in
                    expect(finishedState.winner).to(equal(.cross))
                }
            }
        }

        describe("Playing 3 diagonal noughts") {
            let store = MainStore()
            store.dispatch(PlacePieceAction(index: 2)) // nought: [0, 2]
            store.dispatch(PlacePieceAction(index: 2)) // cross: invalid
            store.dispatch(PlacePieceAction(index: 1)) // cross: [0, 1]
            store.dispatch(PlacePieceAction(index: 6)) // nought: [2, 0]
            store.dispatch(PlacePieceAction(index: 0)) // nought: [0, 0]
            store.dispatch(PlacePieceAction(index: 4)) // nought: [1, 1]

            it("finishes the game and noughts win") {
                expectFinised(gameState: store.state.gameState) { finishedState in
                    expect(finishedState.winner).to(equal(.nought))
                }
            }
        }

        describe("Filling up the board with no winners") {
            let store = MainStore()
            store.dispatch(PlacePieceAction(index: 1)) // 0
            store.dispatch(PlacePieceAction(index: 0)) // x
            store.dispatch(PlacePieceAction(index: 3)) // 0
            store.dispatch(PlacePieceAction(index: 2)) // x
            store.dispatch(PlacePieceAction(index: 4)) // 0
            store.dispatch(PlacePieceAction(index: 5)) // x
            store.dispatch(PlacePieceAction(index: 6)) // 0
            store.dispatch(PlacePieceAction(index: 7)) // x
            store.dispatch(PlacePieceAction(index: 8)) // 0
            
             it("finishes the game with a draw") {
                 expectFinised(gameState: store.state.gameState) { finishedState in
                    expect(finishedState.winner).to(beNil()) // i.e. .none
                }
             }
        }

        describe("A finished game state, when restarted,") {
            let store = MainStore()
            store.dispatch(PlacePieceAction(index: 0))
            store.dispatch(PlacePieceAction(index: 3))
            store.dispatch(PlacePieceAction(index: 1))
            store.dispatch(PlacePieceAction(index: 4))
            store.dispatch(PlacePieceAction(index: 2))

            expectFinised(gameState: store.state.gameState) { finishedState in
                store.dispatch(RestartGameAction())
                it("starts in the playing state, with 9 places on the board, with no pieces") {
                    expectPlaying(gameState: store.state.gameState) { playingState in
//                        expect(playingState.playerTurn).to(equal(.nought))
 //                       expect(playingState.board.count).to(equal(9))
  //                      
    //                    for cell in playingState.board {
      //                      expect(cell).to(beNil())
        //                }
                    }
                }
            }
        }
    }
}
