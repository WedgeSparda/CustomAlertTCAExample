import XCTest
import ComposableArchitecture

@testable import CustomAlertTCAExample

@MainActor
final class CustomAlertTCAExampleTests: XCTestCase {

    private var state: Main.State = .init()
    private var reducer: Main!
    
    override func setUp() {
        super.setUp()
        
        self.reducer = Main()
    }

    func testError() async {
        let store = TestStore(initialState: state, reducer: reducer)
        
        await store.send(.didTapShowWhisperButton, assert: {
            $0.destination = .whisper(.init(message: "This is a test", type: .error))
        })
        
    }

}
