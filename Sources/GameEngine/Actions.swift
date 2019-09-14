import ReSwift

public struct PlacePieceAction: Action {
    public init(at index: Int) {
        self.index = index
    }

    let index: Int
}

public struct RestartGameAction: Action {
    public init() {}
}
