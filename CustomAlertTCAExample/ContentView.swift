import ComposableArchitecture
import SwiftUI

struct Main: Reducer {
    struct State: Equatable {
        @PresentationState var destination: Destination.State?
    }
    
    enum Action: Equatable {
        case didTapButton
        case destination(PresentationAction<Destination.Action>)
    }
    
    struct Destination: Reducer {
        enum State: Equatable, Identifiable {
            case whisper(Whisper.State)
            
            var id: AnyHashable {
                switch self {
                case let .whisper(state):
                    return state.id
                }
            }
        }
        
        enum Action: Equatable {
            case whisper(Whisper.Action)
        }
        
        var body: some ReducerOf<Self> {
            Scope(state: /State.whisper, action: /Action.whisper) {
                Whisper()
            }
        }
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .didTapButton:
                state.destination = .whisper(.init(id: UUID(), message: "This is a test", type: .success))
                return .none
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: /Action.destination) {
            Destination()
        }
    }
}

struct ContentView: View {
    
    let store: StoreOf<Main>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                Button {
                    viewStore.send(.didTapButton)
                } label: {
                    Text("Show Whisper")
                }
            }
//            .whisper(self.store.scope(
//                state: \.$destination,
//                action: /Main.Action.destination
//            ))
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(
            store: .init(
                initialState: .init(),
                reducer: Main()
            )
        )
    }
}
