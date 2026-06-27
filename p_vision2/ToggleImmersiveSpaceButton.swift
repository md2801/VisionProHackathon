// MARK: - ToggleImmersiveSpaceButton.swift
// Body Health Spatial System
// Replace the contents of the default "ToggleImmersiveSpaceButton.swift" with this file.
//
// This button is embedded in ContentView and uses the same AppModel state machine
// as the default Xcode template, extended to style itself for our app.

import SwiftUI

struct ToggleImmersiveSpaceButton: View {

    @EnvironmentObject private var appModel: AppModel

    @Environment(\.openImmersiveSpace)    private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    var body: some View {
        Button {
            Task { @MainActor in
                switch appModel.immersiveSpaceState {

                case .open:
                    appModel.immersiveSpaceState = .inTransition
                    appModel.dismiss()                         // clear any open panels
                    await dismissImmersiveSpace()
                    appModel.immersiveSpaceState = .closed

                case .closed:
                    appModel.immersiveSpaceState = .inTransition
                    switch await openImmersiveSpace(id: appModel.immersiveSpaceID) {
                    case .opened:
                        appModel.immersiveSpaceState = .open
                    case .userCancelled, .error:
                        appModel.immersiveSpaceState = .closed
                    @unknown default:
                        appModel.immersiveSpaceState = .closed
                    }

                case .inTransition:
                    break  // ignore taps while transitioning
                }
            }
        } label: {
            HStack(spacing: 8) {
                if appModel.immersiveSpaceState == .inTransition {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Image(systemName: isOpen ? "xmark.circle.fill" : "arrowshape.forward.fill")
                }
                Text(isOpen ? "Exit Spatial Mode" : "Enter Spatial Mode")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .tint(isOpen ? .red : .blue)
        .disabled(appModel.immersiveSpaceState == .inTransition)
        .animation(.easeInOut(duration: 0.2), value: appModel.immersiveSpaceState)
    }

    private var isOpen: Bool {
        appModel.immersiveSpaceState == .open
    }
}

#Preview {
    ToggleImmersiveSpaceButton()
        .environmentObject(AppModel())
        .padding()
}
