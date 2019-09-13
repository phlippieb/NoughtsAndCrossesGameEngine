import ReSwift

class MainStore: Store<AppState> {
    init() {
        super.init(
            reducer: mainReducer,
            state: nil)
    }

    required init(reducer: @escaping Reducer<State>, state: State?, middleware: [Middleware<State>] = [], automaticallySkipsRepeats: Bool = true) {
        fatalError()
    }
}
