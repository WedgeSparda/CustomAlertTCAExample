import SwiftUI
import ComposableArchitecture

public extension View {
    @ViewBuilder
    func whisper(_ store: StoreOf<Whisper>) -> some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            self.modifier(WhisperViewModifier(viewStore: viewStore))
        }
    }
}


struct WhisperViewModifier: ViewModifier {

    @ObservedObject var viewStore: ViewStoreOf<Whisper>
    
    init(viewStore: ViewStoreOf<Whisper>) {
        self.viewStore = viewStore
    }
    
    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
            WhisperView(viewStore: viewStore)
        }
    }
}
