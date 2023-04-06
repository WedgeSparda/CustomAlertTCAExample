import ComposableArchitecture
import SwiftUI

enum WhisperDismissalTimeInSecondsKey: DependencyKey {
    static let liveValue = 6
    static let testValue = 2
}

extension DependencyValues {
    var dismissalTimeInSeconds: Int {
        get { self[WhisperDismissalTimeInSecondsKey.self] }
        set { self[WhisperDismissalTimeInSecondsKey.self] = newValue }
    }
}

public struct Whisper: Reducer {
    
    private enum CancelID {
        case timer
    }
    @Dependency(\.dismissalTimeInSeconds) var dismissalTimeInSeconds
    @Dependency(\.dismiss) var dismiss
 
    public init() {}
    public struct State: Identifiable, Equatable {
        public let id: UUID
        public let message: String
        public let type: WhisperType
        
        public init(
            id: UUID,
            message: String,
            type: WhisperType
        ) {
            self.id = id
            self.message = message
            self.type = type
        }
    }
    
    public enum Action {
        case didAppear
        case userDidTap
        case userDidClose
    }
        
    public func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .didAppear:
            switch state.type.duration {
            case .infinite:
                return .cancel(id: CancelID.timer)
            case .finite:
                return .run { _ in
                    var tickCount = 0
                    while tickCount < 3 {
                        do {
                            try await Task.sleep(nanoseconds: NSEC_PER_SEC)
                            tickCount += 1
                            if tickCount == dismissalTimeInSeconds {
                                await self.dismiss()
                            }
                        } catch {
                            await self.dismiss()
                        }
                    }
                }
                .cancellable(id: CancelID.timer)
            }
        case .userDidTap, .userDidClose:
            return .run { _ in
                await self.dismiss()
            }
        }
    }
}
