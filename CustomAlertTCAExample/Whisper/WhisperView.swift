import SwiftUI
import ComposableArchitecture

struct WhisperView: View {
    
    let store: StoreOf<Whisper>
    let feedbackGenerator: UIImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                HStack {
                    image(for: viewStore.state.type)
                        .frame(width: 32, height: 32)
                        .padding(.leading)
                    
                    Spacer()
                    
                    closeButton(viewStore: viewStore)
                        .frame(width: 32, height: 32)
                        .padding(.trailing)
                    
                }
                
                HStack {
                    Spacer()
                    
                    Text(viewStore.state.message)
                        .foregroundColor(.white)
                        .padding(.vertical)
                        .padding(.horizontal, 32)
                    
                    Spacer()
                }
            }
            .frame(minHeight: 56)
            .background(Color.black)
            .cornerRadius(8)
            .padding(.horizontal)
            .accessibilityIdentifier("WhisperView")
            .accessibilityValue(viewStore.state.message)
            .onAppear {
                UIAccessibility.post(notification: .announcement, argument: viewStore.state.message)
                feedbackGenerator.prepare()
            }
            .onTapGesture {
                feedbackGenerator.impactOccurred()
                viewStore.send(.userDidTap, animation: .default)
            }
            .transition(.move(edge: .top).combined(with: .opacity))
            .animation(.easeIn(duration: 0.3))
            .zIndex(1)
        }
    }
    
    @ViewBuilder
    private func image(
        for type: WhisperType
    ) -> some View {
        switch type {
        case .error:
            Image("error")
                .renderingMode(.template)
                .foregroundColor(.red)
        case .success:
            Image("success")
                .renderingMode(.template)
                .foregroundColor(.green)
        }
    }
        
    
    @ViewBuilder
    private func closeButton(
        viewStore: ViewStoreOf<Whisper>
    ) -> some View {
        Button {
            feedbackGenerator.impactOccurred()
            viewStore.send(.userDidClose, animation: .default)
        } label: {
            Image("close")
                .renderingMode(.template)
                .foregroundColor(.white)
        }
        .accessibilityIdentifier("Whisper.closeButton")
    }
}

struct ComposableWhisperView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            WhisperView(
                store: .init(
                    initialState: .init(
                        id: UUID(),
                        message: "This is an error message",
                        type: .error
                    ),
                    reducer: Whisper()
                )
            )
            
            WhisperView(
                store: .init(
                    initialState: .init(
                        id: UUID(),
                        message: "This is a success message",
                        type: .success
                    ),
                    reducer: Whisper()
                )
            )
            
        }
        .previewDisplayName("Whisper types")
    }
}

public extension View {
    func whisper<DestinationState, DestinationAction>(
        store: Store<DestinationState?, PresentationAction<DestinationAction>>,
        state toWhisperState: @escaping (DestinationState) -> Whisper.State?,
        action fromWhisperAction: @escaping (Whisper.Action) -> DestinationAction
    ) -> some View {
        self.whisper(
            store: store.scope(
                state: { $0.flatMap(toWhisperState) },
                action: {
                    switch $0 {
                    case .dismiss:
                        return .dismiss
                    case let .presented(action):
                        return .presented(fromWhisperAction(action))
                    }
                }
            )
        )
    }
    
    func whisper(
        store: Store<Whisper.State?, PresentationAction<Whisper.Action>>
    ) -> some View {
        WithViewStore(
            store,
            observe: { $0?.id },
            removeDuplicates: { ($0 != nil) == ($1 != nil) }
        ) { viewStore in
            self.whisper(
                isPresented: Binding(
                    get: { viewStore.state != nil },
                    set: { isActive in
                        if !isActive, viewStore.state != nil {
                            viewStore.send(.dismiss)
                        }
                    }
                ),
                store: store
            )
        }
    }
    
    @ViewBuilder
    func whisper(
        isPresented: Binding<Bool>,
        store: Store<Whisper.State?, PresentationAction<Whisper.Action>>
    ) -> some View {
        if isPresented.wrappedValue {
            IfLetStore(
                store.scope(
                    state: returningLastNonNilValue { $0 },
                    action: { .presented($0) }
                )
            ) { store in
                self.modifier(WhisperViewModifier(store: store))
            }
        }
    }
}


struct WhisperViewModifier: ViewModifier {
    
    let store: StoreOf<Whisper>
    
    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
            WhisperView(store: store)
        }
    }
}

func returningLastNonNilValue<A, B>(
    _  f: @escaping (A) -> B?
) -> (A) -> B? {
    var lastValue: B?
    return { a in
        lastValue = f(a) ?? lastValue
        return lastValue
    }
}
