import ComposableArchitecture
import SwiftUI

struct Main: Reducer {
    struct State: Equatable {
        @PresentationState var destination: Destination.State?
    }
    
    enum Action: Equatable {
        case didTapShowWhisperButton
        case didTapHideAllButton
        case didTapShowAlertButton
        case didTapUpdateWhisperButton
        case destination(PresentationAction<Destination.Action>)
        
        enum Alert: Equatable {
            case showWhisper
        }
    }
    
    struct Destination: Reducer {
        enum State: Equatable {
            case whisper(Whisper.State)
            case alert(AlertState<Main.Action.Alert>)
        }
        
        enum Action: Equatable {
            case whisper(Whisper.Action)
            case alert(Main.Action.Alert)
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
            case .didTapShowWhisperButton:
                showWhisperIfNeeded(state: &state)
                return .none
            case .didTapHideAllButton:
                state.destination = nil
                return .none
            case .didTapShowAlertButton:
                showAlert(state: &state)
                return .none
            case .didTapUpdateWhisperButton:
                guard case .whisper = state.destination else {
                    return .none
                }
                return .send(.destination(.presented(.whisper(.updateWhisper(type: .error, message: "Oops some failed!")))))
            case .destination(.presented(.alert(.showWhisper))):
                showWhisper(state: &state)
                return .none
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: /Action.destination) {
            Destination()
        }
    }
    
    private func showWhisperIfNeeded(state: inout State) {
        guard state.destination == nil else {
            return
        }
        showWhisper(state: &state)
    }
    
    private func showWhisper(state: inout State) {
        state.destination = .whisper(
            .init(
                message: "This is a test",
                type: .error
            )
        )
    }

    private func showAlert(state: inout State) {
        state.destination = .alert(.showWhisper())
    }

}

extension AlertState where Action == Main.Action.Alert {
    static func showWhisper() -> Self {
        AlertState {
            TextState("This is a test")
        } actions: {
            ButtonState(action: .send(.showWhisper, animation: .default)) {
                TextState("SHOW WHISPER")
            }
        }
    }
}
struct ContentView: View {
    
    let store: StoreOf<Main>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 30) {
                Spacer()
                Button {
                    viewStore.send(.didTapShowWhisperButton)
                } label: {
                    Text("Show Whisper")
                }
                Button {
                    viewStore.send(.didTapUpdateWhisperButton)
                } label: {
                    Text("Update Whisper")
                }
                Button {
                    viewStore.send(.didTapShowAlertButton)
                } label: {
                    Text("Show Alert")
                }
                Spacer()
                Button {
                    viewStore.send(.didTapHideAllButton, animation: .default)
                } label: {
                    Text("Hide All")
                }
                Spacer()
            }
            .whisper(
                store: self.store.scope(
                    state: \.destination,
                    action: Main.Action.destination
                ),
                state: /Main.Destination.State.whisper,
                action: Main.Destination.Action.whisper
            )
            .alert(
                store: self.store.scope(
                    state: \.$destination,
                    action: Main.Action.destination
                ),
                state: /Main.Destination.State.alert,
                action: Main.Destination.Action.alert
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
        
        ContentView(
            store: .init(
                initialState: .init(
                    destination: .whisper(
                        .init(
//                            id: UUID(),
                            message: "OLA KE ASE",
                            type: .success
                        )
                    )
                ),
                reducer: Main()
            )
        )

    }
}
