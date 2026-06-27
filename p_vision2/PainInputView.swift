// MARK: - PainInputView.swift
// Body Health Spatial System
// ADD this as a new Swift file to the p_vision2 target.
//
// A floating SwiftUI panel that appears in 3D space near the tapped body region.
// Rendered as a RealityView Attachment — a genuine 3D entity, not a 2D overlay.
//
// Contents:
//   • Body region label + header
//   • Pain level slider (1–10) with colour-coded severity badge
//   • Free-text symptom input (multiline)
//   • Voice input placeholder button
//   • "Analyse with AI" submit button

import SwiftUI

struct PainInputView: View {

    // MARK: Inputs
    let painLog:   PainLog
    let onSubmit:  (PainLog) -> Void
    let onDismiss: () -> Void

    // MARK: Local state
    @State private var painLevel:       Double
    @State private var symptoms:        String = ""
    @State private var isVoiceActive:   Bool   = false
    @FocusState private var fieldFocused: Bool

    init(painLog: PainLog,
         onSubmit: @escaping (PainLog) -> Void,
         onDismiss: @escaping () -> Void) {
        self.painLog   = painLog
        self.onSubmit  = onSubmit
        self.onDismiss = onDismiss
        _painLevel     = State(initialValue: Double(painLog.painLevel))
    }

    // MARK: Derived
    private var painInt: Int { Int(painLevel) }

    private var severityColor: Color {
        switch painInt {
        case 1...3:  return .green
        case 4...6:  return .yellow
        case 7...8:  return .orange
        default:     return .red
        }
    }

    private var severityLabel: String {
        switch painInt {
        case 1...3:  return "Mild"
        case 4...6:  return "Moderate"
        case 7...8:  return "Significant"
        default:     return "Severe"
        }
    }

    // MARK: Body
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── Header ──────────────────────────────────────────────────
            headerSection
            Divider().padding(.horizontal, 20)

            // ── Scrollable content ───────────────────────────────────────
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    painSliderSection
                    Divider()
                    symptomInputSection
                    voiceInputButton
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 18)
            }

            Divider().padding(.horizontal, 20)

            // ── Submit ───────────────────────────────────────────────────
            submitSection
        }
        .frame(width: 340)
        .glassBackgroundEffect(
            in: RoundedRectangle(cornerRadius: 26, style: .continuous)
        )
    }

    // MARK: - Subviews

    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Pain Report")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .tracking(0.8)
                Text(painLog.region.displayName)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
            }
            Spacer()
            // Close / dismiss button
            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(.secondary)
                    .symbolRenderingMode(.hierarchical)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 14)
    }

    private var painSliderSection: some View {
        VStack(alignment: .leading, spacing: 10) {

            // Label row + live badge
            HStack {
                Label("Pain Level", systemImage: "waveform.path.ecg")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
                Spacer()
                // Severity badge
                HStack(spacing: 5) {
                    Text("\(painInt)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(severityColor)
                    Text("/ 10  ·  \(severityLabel)")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(severityColor.opacity(0.8))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    severityColor.opacity(0.12),
                    in: RoundedRectangle(cornerRadius: 10, style: .continuous)
                )
                .animation(.spring(response: 0.25), value: painInt)
            }

            // Slider
            Slider(value: $painLevel, in: 1...10, step: 1)
                .tint(severityColor)
                .animation(.spring(response: 0.2), value: painLevel)

            // Range labels
            HStack {
                Text("Mild")
                Spacer()
                Text("Severe")
            }
            .font(.system(size: 11, design: .rounded))
            .foregroundStyle(.tertiary)
        }
    }

    private var symptomInputSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Describe Symptoms", systemImage: "text.bubble")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)

            TextField(
                "e.g. sharp pain, stiffness, swelling, numbness…",
                text: $symptoms,
                axis: .vertical
            )
            .lineLimit(3...5)
            .font(.system(size: 15, design: .rounded))
            .focused($fieldFocused)
            .padding(12)
            .background(.ultraThinMaterial,
                        in: RoundedRectangle(cornerRadius: 13, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .strokeBorder(
                        fieldFocused ? Color.blue.opacity(0.55) : Color.clear,
                        lineWidth: 1.5
                    )
            )
            .animation(.easeInOut(duration: 0.18), value: fieldFocused)
        }
    }

    private var voiceInputButton: some View {
        Button {
            isVoiceActive.toggle()
            // TODO: In production, start / stop SFSpeechRecognizer session here
            //       and append recognised text to `symptoms`.
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(isVoiceActive
                              ? Color.red.opacity(0.18)
                              : Color.blue.opacity(0.10))
                        .frame(width: 38, height: 38)
                    Image(systemName: isVoiceActive ? "waveform" : "mic.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(isVoiceActive ? .red : .blue)
                        .symbolEffect(.pulse, isActive: isVoiceActive)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(isVoiceActive ? "Recording…" : "Voice Input")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                    Text(isVoiceActive
                         ? "Tap again to stop"
                         : "Describe your symptoms aloud")
                        .font(.system(size: 11, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                Spacer()

                if isVoiceActive {
                    // Animated recording dot
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                        .symbolEffect(.pulse, isActive: true)
                }
            }
            .padding(13)
            .background(.ultraThinMaterial,
                        in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var submitSection: some View {
        VStack(spacing: 10) {
            Button {
                var updated        = painLog
                updated.painLevel  = painInt
                updated.symptoms   = symptoms
                onSubmit(updated)
            } label: {
                Label("Analyse with AI", systemImage: "sparkles")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(.blue)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

#Preview {
    PainInputView(
        painLog: PainLog(region: .leftWrist),
        onSubmit: { _ in },
        onDismiss: { }
    )
}
