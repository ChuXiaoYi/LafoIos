import SwiftUI

@main
struct LafoApp: App {
    @StateObject private var store = LafoStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
