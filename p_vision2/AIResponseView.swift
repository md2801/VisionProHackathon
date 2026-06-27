// MARK: - AIResponseView.swift
// Body Health Spatial System
// ADD this as a new Swift file to the p_vision2 target.
//
// Floating spatial panel displaying AI-generated health suggestions.
// Cards animate in one-by-one with a spring stagger effect.
// AIEngine (mock) lives at the bottom of this file..

import SwiftUI

// MARK: - AIResponseView

struct AIResponseView: View {

    let region:      BodyRegion
    let painLevel:   Int
    let suggestions: [AISuggestion]
    let onDismiss:   () -> Void

    // Stagger animation state
    @State private var revealedCount: Int   = 0
    @State private var headerVisible: Bool  = false

    // MARK: Severity helper
    private var severity: (label: String, color: Color, icon: String) {
        switch painLevel {
        case 1...3:  return ("Mild",        .green,  "checkmark.seal.fill")
        case 4...6:  return ("Moderate",    .yellow, "exclamationmark.triangle.fill")
        case 7...8:  return ("Significant", .orange, "exclamationmark.octagon.fill")
        default:     return ("Severe",      .red,    "xmark.octagon.fill")
        }
    }

    // MARK: Body
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── Header ───────────────────────────────────────────────────
            headerSection
                .opacity(headerVisible ? 1 : 0)
                .offset(y: headerVisible ? 0 : 8)

            Divider().padding(.horizontal, 20)

            // ── Suggestion cards ─────────────────────────────────────────
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(Array(suggestions.enumerated()), id: \.element.id) { idx, item in
                        SuggestionCard(suggestion: item)
                            .opacity(revealedCount > idx ? 1 : 0)
                            .offset(y: revealedCount > idx ? 0 : 14)
                            .animation(
                                .spring(response: 0.44, dampingFraction: 0.78)
                                    .delay(Double(idx) * 0.11),
                                value: revealedCount
                            )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }

            Divider().padding(.horizontal, 20)

            // ── Footer ───────────────────────────────────────────────────
            footerSection
        }
        .frame(width: 360)
        .glassBackgroundEffect(
            in: RoundedRectangle(cornerRadius: 26, style: .continuous)
        )
        .onAppear {
            withAnimation(.easeOut(duration: 0.32)) { headerVisible = true }
            // Slight delay before cards start cascading
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                withAnimation { revealedCount = suggestions.count }
            }
        }
    }

    // MARK: - Subviews

    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("AI Health Insights")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .tracking(0.8)
                Text(region.displayName)
                    .font(.system(size: 22, weight: .bold, design: .rounded))

                // Severity badge
                HStack(spacing: 6) {
                    Image(systemName: severity.icon)
                        .font(.system(size: 12, weight: .semibold))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(severity.color)
                    Text("\(severity.label) — Level \(painLevel)/10")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(severity.color.opacity(0.9))
                }
                .padding(.horizontal, 9)
                .padding(.vertical, 5)
                .background(
                    severity.color.opacity(0.12),
                    in: RoundedRectangle(cornerRadius: 9, style: .continuous)
                )
            }
            Spacer()
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

    private var footerSection: some View {
        VStack(spacing: 10) {
            // Medical disclaimer
            Text("⚠ AI-generated insights only. Consult a licensed healthcare professional for diagnosis and treatment.")
                .font(.system(size: 10, design: .rounded))
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            // Done button
            Button(action: onDismiss) {
                Label("Done", systemImage: "checkmark")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(.blue)
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 16)
    }
}

// MARK: - SuggestionCard

private struct SuggestionCard: View {
    let suggestion: AISuggestion

    var body: some View {
        HStack(alignment: .top, spacing: 14) {

            // Category icon
            ZStack {
                Circle()
                    .fill(suggestion.category.color.opacity(0.14))
                    .frame(width: 44, height: 44)
                Image(systemName: suggestion.category.systemImage)
                    .font(.system(size: 19, weight: .medium))
                    .foregroundStyle(suggestion.category.color)
                    .symbolRenderingMode(.hierarchical)
            }

            // Text content
            VStack(alignment: .leading, spacing: 4) {
                Text(suggestion.title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                Text(suggestion.detail)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .background(
            .ultraThinMaterial,
            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(
                    suggestion.category.color.opacity(0.22),
                    lineWidth: 1
                )
        )
    }
}

// MARK: - AIEngine  (Mock — swap for real API in production)

enum AIEngine {

    /// Returns region-specific and severity-adjusted health suggestions.
    /// To integrate a real LLM, replace this function body with an async network call.
    static func generateSuggestion(
        for region: String,
        painLevel: Int,
        symptoms: String
    ) -> [AISuggestion] {

        var results: [AISuggestion]

        switch region {

        // ── Head ─────────────────────────────────────────────────────────
        case "head":
            results = [
                .init(icon: "brain",           title: "Possible tension headache",
                      detail: "Commonly caused by stress, dehydration, or prolonged screen exposure.",
                      category: .diagnosis),
                .init(icon: "drop.fill",        title: "Increase fluid intake",
                      detail: "Aim for 8–10 glasses of water daily. Dehydration is a leading trigger.",
                      category: .action),
                .init(icon: "moon.stars.fill",  title: "Rest in a dark, quiet space",
                      detail: "Reduce light and sound stimulation. Light sensitivity may indicate migraine.",
                      category: .lifestyle)
            ]

        // ── Neck ─────────────────────────────────────────────────────────
        case "neck":
            results = [
                .init(icon: "figure.seated.seatbelt", title: "Likely postural muscle strain",
                      detail: "Prolonged forward head posture increases load on cervical muscles significantly.",
                      category: .diagnosis),
                .init(icon: "figure.cooldown", title: "Gentle neck stretches",
                      detail: "Slowly rotate head left and right, then tilt ear to shoulder — hold 20 s each side.",
                      category: .action),
                .init(icon: "desktopcomputer", title: "Raise screen to eye level",
                      detail: "Every 2.5 cm of screen drop below eye level adds ~5 kg of apparent neck load.",
                      category: .lifestyle)
            ]

        // ── Shoulders ────────────────────────────────────────────────────
        case "left_shoulder", "right_shoulder":
            let side = region.hasPrefix("left") ? "left" : "right"
            results = [
                .init(icon: "figure.arms.open", title: "Possible rotator cuff strain",
                      detail: "Common in overhead activities. Check for pain on raising the \(side) arm above 90°.",
                      category: .diagnosis),
                .init(icon: "figure.flexibility", title: "Pendulum exercise",
                      detail: "Lean forward, let the arm hang loose, and make small circles — 3 × 30 s.",
                      category: .action),
                .init(icon: "bed.double.fill",  title: "Avoid sleeping on affected side",
                      detail: "Side-sleeping compresses the bursa and can worsen morning stiffness.",
                      category: .lifestyle)
            ]

        // ── Wrists ───────────────────────────────────────────────────────
        case "left_wrist", "right_wrist":
            results = [
                .init(icon: "hand.raised.fingers.spread.fill", title: "Possible RSI or carpal tunnel",
                      detail: "Repetitive wrist flexion from typing, clicking, or gaming is the primary cause.",
                      category: .diagnosis),
                .init(icon: "bandage.fill",   title: "Brace and rest for 48 hours",
                      detail: "A neutral-position wrist brace reduces tendon irritation during recovery.",
                      category: .action),
                .init(icon: "thermometer.snowflake", title: "Ice therapy protocol",
                      detail: "Apply an ice pack for 15 min every 2 hours during the first 2 days.",
                      category: .action)
            ]

        // ── Chest ────────────────────────────────────────────────────────
        case "chest":
            results = [
                .init(icon: "heart.fill",     title: "Evaluate chest pain carefully",
                      detail: "Seek emergency care immediately if pain radiates to your arm, jaw, or is crushing.",
                      category: .warning),
                .init(icon: "lungs.fill",     title: "Deep diaphragmatic breathing",
                      detail: "Breathe in for 4 s, hold 2 s, out for 6 s. If this worsens pain, stop and seek help.",
                      category: .action),
                .init(icon: "cross.case.fill", title: "Professional evaluation recommended",
                      detail: "Chest pain at moderate–high levels should always be assessed by a clinician.",
                      category: .warning)
            ]

        // ── Upper / Lower Back ────────────────────────────────────────────
        case "upper_back":
            results = [
                .init(icon: "figure.walk",    title: "Thoracic muscle tension",
                      detail: "Often from hunching over a desk. The rhomboids and trapezius are commonly involved.",
                      category: .diagnosis),
                .init(icon: "figure.yoga",    title: "Doorway chest stretch",
                      detail: "Stand in a doorway, arms at 90°, lean gently forward — hold 30 s, repeat × 3.",
                      category: .action),
                .init(icon: "chair.lounge.fill", title: "Engage shoulder blades",
                      detail: "Consciously retract and depress shoulder blades throughout the day.",
                      category: .lifestyle)
            ]

        case "lower_back":
            results = [
                .init(icon: "figure.walk",    title: "Lumbar strain most likely",
                      detail: "Low back pain is among the most common musculoskeletal issues globally.",
                      category: .diagnosis),
                .init(icon: "figure.yoga",    title: "Cat-cow and bird-dog",
                      detail: "Perform 2 sets of 10 reps each. These decompress lumbar facet joints gently.",
                      category: .action),
                .init(icon: "chair.lounge.fill", title: "Lumbar support & posture",
                      detail: "Maintain the natural lordotic curve. Avoid sitting > 45 min without a break.",
                      category: .lifestyle)
            ]

        // ── Knees ────────────────────────────────────────────────────────
        case "left_knee", "right_knee":
            results = [
                .init(icon: "figure.run",     title: "Patellar inflammation likely",
                      detail: "Runner's knee or patellar tendinitis are common with repeated impact loading.",
                      category: .diagnosis),
                .init(icon: "figure.open.water.swim", title: "Switch to low-impact exercise",
                      detail: "Swimming or cycling maintains cardiovascular fitness without compressive joint load.",
                      category: .action),
                .init(icon: "bandage.fill",   title: "RICE protocol",
                      detail: "Rest · Ice · Compression · Elevation — first-line care for acute knee pain.",
                      category: .action)
            ]

        // ── Ankles ───────────────────────────────────────────────────────
        case "left_ankle", "right_ankle":
            results = [
                .init(icon: "figure.walk",    title: "Possible ligament sprain",
                      detail: "Lateral ankle sprains account for ~85 % of all ankle injuries.",
                      category: .diagnosis),
                .init(icon: "bandage.fill",   title: "RICE protocol immediately",
                      detail: "Elevate the ankle above heart level and apply compression within the first hour.",
                      category: .action),
                .init(icon: "figure.stand",   title: "Progressive weight-bearing",
                      detail: "Begin gentle weight-bearing as pain allows. Full immobilisation slows healing.",
                      category: .lifestyle)
            ]

        // ── Abdomen ──────────────────────────────────────────────────────
        case "abdomen":
            results = [
                .init(icon: "stomach",        title: "GI discomfort or muscle strain",
                      detail: "Abdominal pain can be muscular (after exercise) or visceral. Location matters.",
                      category: .diagnosis),
                .init(icon: "fork.knife",     title: "Eat smaller, frequent meals",
                      detail: "Large meals increase intra-abdominal pressure and can exacerbate discomfort.",
                      category: .action),
                .init(icon: "cross.case.fill", title: "Monitor for 24 hours",
                      detail: "Seek urgent care if pain is sharp, localised to lower right, or accompanied by fever.",
                      category: .warning)
            ]

        // ── Default fallback ─────────────────────────────────────────────
        default:
            results = [
                .init(icon: "waveform.path.ecg", title: "Musculoskeletal discomfort",
                      detail: "Localised pain most often originates in muscle, tendon, or joint tissue.",
                      category: .diagnosis),
                .init(icon: "drop.fill",     title: "Stay hydrated",
                      detail: "Hydration supports tissue repair and can reduce localised inflammation.",
                      category: .action),
                .init(icon: "bed.double.fill", title: "Prioritise rest",
                      detail: "Allow the affected area adequate recovery time before resuming normal load.",
                      category: .lifestyle)
            ]
        }

        // ── Universal severity escalation ─────────────────────────────────
        switch painLevel {
        case 7...:
            results.append(.init(
                icon: "stethoscope",
                title: "Seek professional evaluation",
                detail: "Pain at level \(painLevel)/10 warrants in-person assessment to rule out serious pathology.",
                category: .warning
            ))
        case 4...6:
            results.append(.init(
                icon: "figure.walk.motion",
                title: "Monitor over 48 hours",
                detail: "If pain persists or escalates, contact your GP or physiotherapist promptly.",
                category: .lifestyle
            ))
        default:
            results.append(.init(
                icon: "checkmark.circle.fill",
                title: "Mild — self-care appropriate",
                detail: "Gentle movement, hydration, and rest should resolve mild pain within 1–2 days.",
                category: .lifestyle
            ))
        }

        return results
    }
}

// MARK: Preview

#Preview {
    AIResponseView(
        region: .leftKnee,
        painLevel: 6,
        suggestions: AIEngine.generateSuggestion(
            for: "left_knee",
            painLevel: 6,
            symptoms: "stiffness after running"
        ),
        onDismiss: { }
    )
}
