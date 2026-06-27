// MARK: - ContentView.swift.
import SwiftUI

struct ContentView: View {

    @EnvironmentObject private var appModel: AppModel
    @Environment(\.openImmersiveSpace)    var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    var body: some View {
        VStack(spacing: 20) {

            // MARK: — Header
            VStack(spacing: 6) {
                Image(systemName: "figure.arms.open")
                    .font(.system(size: 44, weight: .ultraLight))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.cyan, .blue, .indigo],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .symbolEffect(.pulse, options: .repeating)

                Text("Somatic")
                    .font(.system(size: 28, weight: .bold, design: .rounded))

                Text("Your body. Your data. Your space.")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            Divider()

            // MARK: — Health Ring + Stats
            HStack(spacing: 20) {

                // Ring
                ZStack {
                    Circle()
                        .stroke(Color.green.opacity(0.15), lineWidth: 8)
                    Circle()
                        .trim(from: 0, to: 0.72)
                        .stroke(Color.green,
                                style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    VStack(spacing: 1) {
                        Text("72")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(.green)
                        Text("Health")
                            .font(.system(size: 10, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 72, height: 72)

                // Stats grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())],
                          spacing: 8) {
                    MiniStat(icon: "heart.fill",      color: .red,    label: "Heart",    value: "72 BPM")
                    MiniStat(icon: "lungs.fill",      color: .blue,   label: "Lungs",    value: "14 br/m")
                    MiniStat(icon: "moon.stars.fill", color: .indigo, label: "Sleep",    value: "7.4 hrs")
                    MiniStat(icon: "flame.fill",      color: .orange, label: "Calories", value: "430 kcal")
                }
            }
            .padding(.horizontal, 8)

            Divider()

            // MARK: — How it works
            VStack(alignment: .leading, spacing: 10) {
                HowToRow(icon: "eyes",                color: .cyan,   text: "Look at a body region to hover")
                HowToRow(icon: "hand.tap.fill",       color: .blue,   text: "Pinch to select — region glows")
                HowToRow(icon: "slider.horizontal.3", color: .indigo, text: "Rate pain and describe symptoms")
                HowToRow(icon: "sparkles",            color: .purple, text: "Get floating AI insights in space")
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Divider()

            // MARK: — Enter / Exit button
            Button {
                Task {
                    switch appModel.immersiveSpaceState {
                    case .open:
                        await dismissImmersiveSpace()
                        appModel.immersiveSpaceState = .closed
                    case .closed:
                        appModel.immersiveSpaceState = .inTransition
                        await openImmersiveSpace(id: appModel.immersiveSpaceID)
                        appModel.immersiveSpaceState = .open
                    case .inTransition:
                        break
                    }
                }
            } label: {
                Label(
                    appModel.immersiveSpaceState == .open ? "Exit Body View" : "Enter Your Body",
                    systemImage: appModel.immersiveSpaceState == .open
                        ? "xmark.circle" : "figure.stand"
                )
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
            }
            .buttonStyle(.borderedProminent)
            .disabled(appModel.immersiveSpaceState == .inTransition)

            if appModel.immersiveSpaceState == .inTransition {
                HStack(spacing: 6) {
                    ProgressView().scaleEffect(0.8)
                    Text("Opening spatial view…")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(24)
        .frame(width: 340)
        .glassBackgroundEffect()
    }
}

// MARK: - Mini Stat Card

private struct MiniStat: View {
    let icon:  String
    let color: Color
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundStyle(color)
                .frame(width: 26, height: 26)
                .background(color.opacity(0.12), in: Circle())

            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                Text(label)
                    .font(.system(size: 10, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - How To Row

private struct HowToRow: View {
    let icon:  String
    let color: Color
    let text:  String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(color)
                .frame(width: 28, height: 28)
                .background(color.opacity(0.12), in: Circle())

            Text(text)
                .font(.system(size: 13, design: .rounded))
                .foregroundStyle(.secondary)
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environmentObject(AppModel())
}
