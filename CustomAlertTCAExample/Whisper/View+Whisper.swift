import SwiftUI
import ComposableArchitecture

public extension View {

    func whisper<DestinationState, DestinationAction>(
        _ store: Store<DestinationState?, PresentationAction<DestinationAction>>,
        state toWhisperState: @escaping (DestinationState) -> Whisper.State?,
        action fromWhisperAction: @escaping (Whisper.Action) -> DestinationAction
    ) -> some View {
        self.modifier(
            WhisperViewModifier(
                store: store.scope(
                    state: {
                        $0.flatMap(toWhisperState)
                    },
                    action: {
                        switch $0 {
                        case .didAppear:
                            return .presented(fromWhisperAction($0))
                        case .userDidTap:
                            return .dismiss
                        case .userDidClose:
                            return .dismiss
                        }
                    }
                )
            )
        )
    }
}


struct WhisperViewModifier: ViewModifier {

    var store: Store<Whisper.State?, Whisper.Action>
    
    init(store: Store<Whisper.State?, Whisper.Action>) {
        self.store = store
    }
    
    func body(content: Content) -> some View {
        WithViewStore(
            store,
            observe: { $0 },
            removeDuplicates: { ($0 != nil) == ($1 != nil) }
        ) { viewStore in
            ZStack(alignment: .top) {
                content
                    .zIndex(0)
                WhisperView(viewStore: viewStore)
                    .zIndex(1)
            }
        }
    }
}
