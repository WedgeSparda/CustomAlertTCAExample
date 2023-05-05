import SwiftUI
import ComposableArchitecture

struct WhisperView: View {
    
    let viewStore: ViewStoreOf<Whisper>
    let feedbackGenerator: UIImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
//        WithViewStore(store, observe: { $0 }) { viewStore in
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
//        }
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
    static let errorStore = ViewStore(
        Store(
            initialState: .init(
                id: UUID(),
                message: "This is an error message",
                type: .error
            ),
            reducer: Whisper()
        ),
        observe: {$0}
    )
    
    static let successStore = ViewStore(
        Store(
            initialState: .init(
                id: UUID(),
                message: "This is a success message",
                type: .success
            ),
            reducer: Whisper()
        ),
        observe: {$0}
    )
    
    static var previews: some View {
        VStack {
            WhisperView(viewStore: errorStore)
            
            WhisperView(viewStore: successStore)
        }
        .previewDisplayName("Whisper types")
    }
}
