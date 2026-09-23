import SwiftData
import SwiftUI

@main
struct SpoonFitApp: App {
    private let modelContainer: ModelContainer

    init() {
        let schema = Schema([ProgramState.self, CompletedSession.self])
        if let container = try? ModelContainer(for: schema) {
            modelContainer = container
        } else {
            // A corrupt or unreadable store should never stop the app from
            // opening: fall back to memory so this launch still works.
            modelContainer = try! ModelContainer(
                for: schema,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(modelContainer)
    }
}
