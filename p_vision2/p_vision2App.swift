//
import SwiftUI

@main
struct p_vision2App: App {

    @StateObject private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appModel)
        }
        .windowStyle(.automatic)
        .defaultSize(width: 620, height: 680)

        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environmentObject(appModel)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}
