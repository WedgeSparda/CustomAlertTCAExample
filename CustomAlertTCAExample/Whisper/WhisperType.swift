import Foundation

public enum WhisperType: Equatable {
    case success
    case error
    
    public enum Duration {
        case finite
        case infinite
    }
            
    var duration: Duration {
        switch self {
        case .success: return .finite
        case .error: return .infinite
        }
    }
}
