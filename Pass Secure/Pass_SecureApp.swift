//
//
//
//
//
//  swiftdata related code is inspired by example "SwiftDataExample" by Sean Allen on 9/27/23

import SwiftUI
import SwiftData

@main
struct PassVault: App {
    
    let container: ModelContainer = {
        let schema = Schema([PCRecord.self])
        let config = ModelConfiguration(cloudKitDatabase: .private("iCloud.dev.orpheuslau"))
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        let container = try! ModelContainer(for: schema, configurations: [modelConfiguration])
        return container
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
