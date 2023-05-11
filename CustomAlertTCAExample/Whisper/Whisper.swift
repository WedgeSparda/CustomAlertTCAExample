import ComposableArchitecture
import SwiftUI

enum WhisperDismissalTimeInSecondsKey: DependencyKey {
    static let liveValue = 6
    static let testValue = 1
}

extension DependencyValues {
    var whisperDismissalTimeInSeconds: Int {
        get { self[WhisperDismissalTimeInSecondsKey.self] }
        set { self[WhisperDismissalTimeInSecondsKey.self] = newValue }
    }
}

public struct Whisper: Reducer {
    
    private enum CancelID {
        case timer
    }
    @Dependency(\.whisperDismissalTimeInSeconds) var dismissalTimeInSeconds
    @Dependency(\.dismiss) var dismiss
 
    public init() {}
    public struct State: Identifiable, Equatable {
        public let id: UUID
        public var message: String
        public var type: WhisperType
        
        internal let whisperHiddenOffset: CGSize = .init(width: 0, height: -150)
        internal let whisperPresentedOffset: CGSize = .zero
        internal var whisperOffset: CGSize
        
        public init(
            id: UUID,
            message: String,
            type: WhisperType
        ) {
            self.id = id
            self.message = message
            self.type = type
            self.whisperOffset = whisperHiddenOffset
        }
    }
    
    public enum Action: Equatable {
        case didAppear
        case startInternalTimer
        
        case userDidTap
        case userDidClose
        case dismiss
        
        case updateWhisper(type: WhisperType, message: String)
        case updateWhisperOffset(offset: CGSize)
    }
        
    public func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .didAppear:
            return .concatenate(
                .run { [offset = state.whisperPresentedOffset] send in
                    await send(.updateWhisperOffset(offset: offset), animation: .spring())
                },
                .run { send in
                    await send(.startInternalTimer)
                }
            )
        case .startInternalTimer:
            switch state.type.duration {
            case .infinite:
                return .cancel(id: CancelID.timer)
            case .finite:
                return .run { send in
                    var tickCount = 0
                    while tickCount <= dismissalTimeInSeconds {
                        try await Task.sleep(nanoseconds: NSEC_PER_SEC)
                        tickCount += 1
                        if tickCount == dismissalTimeInSeconds {
                            await send(.dismiss, animation: .easeInOut)
                        }
                    }
                }
                .cancellable(id: CancelID.timer)
            }
        case .userDidTap, .userDidClose:
            return .run { send in
                await send(.dismiss, animation: .easeInOut)
            }
        case .dismiss:
            return .concatenate(
                .run { [offset = state.whisperHiddenOffset] send in
                    await send(.updateWhisperOffset(offset: offset), animation: .easeInOut)
                },
                .run { _ in
                    try await Task.sleep(nanoseconds: NSEC_PER_SEC / 3)
                    await self.dismiss()
                }
            )
        case let .updateWhisperOffset(offset):
            state.whisperOffset = offset
            return .none
            
        case let.updateWhisper(type, message):
            state.type = type
            state.message = message
            return .none
        }
    }
}
