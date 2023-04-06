import ComposableArchitecture
import SwiftUI

struct Main: Reducer {
    struct State: Equatable {
        var destination: Destination.State?
    }
    
    enum Action {
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
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .didTapButton:
                state.destination = .whisper(.init(id: UUID(), message: "This is a test", type: .success))
                return .none
            case .destination:
                return .none
            }
        }
        // Getting "Key path value type 'Main.Destination.State?' cannot be converted to contextual type 'PresentationState<DestinationState>'" if this line is not commented
//        .ifLet(\.destination, action: /Action.destination)
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
            .whisper(
                store: self.store.scope(
                    state: \.destination,
                    action: Main.Action.destination
                ),
                state: /Main.Destination.State.whisper,
                action: Main.Destination.Action.whisper
            )
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
