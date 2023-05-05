import SwiftUI

@main
struct CustomAlertTCAExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(
                store: .init(
                    initialState: .init(),
                    reducer: Main()
                )
            )
        }
    }
}
