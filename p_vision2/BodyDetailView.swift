// MARK: - BodyDetailView.swift.
import SwiftUI

struct BodyDetailView: View {
    let region:    BodyRegion
    let onDismiss: () -> Void

    private var detail: RegionDetail { region.detail }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Header
            HStack(spacing: 12) {
                Image(systemName: detail.icon)
                    .font(.system(size: 20))
                    .foregroundStyle(detail.color)
                    .frame(width: 42, height: 42)
                    .background(detail.color.opacity(0.15),
                                in: RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 2) {
                    Text(detail.title)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                    Text(detail.subtitle)
                        .font(.system(size: 12, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 12)

            // Metric pill
            HStack(spacing: 8) {
                Text(detail.metricValue)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(detail.color)
                Text(detail.metricUnit)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(.secondary)
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: detail.trendUp
                          ? "arrow.up.right" : "arrow.down.right")
                        .font(.system(size: 11))
                    Text(detail.trend)
                        .font(.system(size: 12, design: .rounded))
                }
                .foregroundStyle(detail.trendUp ? Color.green : Color.orange)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    (detail.trendUp ? Color.green : Color.orange).opacity(0.12),
                    in: RoundedRectangle(cornerRadius: 8)
                )
            }
            .padding(12)
            .background(detail.color.opacity(0.08),
                        in: RoundedRectangle(cornerRadius: 12))
            .padding(.bottom, 12)

            Divider().padding(.bottom, 12)

            // Sections
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(detail.sections) { section in
                        VStack(alignment: .leading, spacing: 7) {
                            Text(section.title)
                                .font(.system(size: 11, weight: .semibold,
                                              design: .rounded))
                                .foregroundStyle(.secondary)
                                .textCase(.uppercase)
                            ForEach(section.items, id: \.self) { item in
                                HStack(alignment: .top, spacing: 8) {
                                    Circle()
                                        .fill(detail.color)
                                        .frame(width: 5, height: 5)
                                        .padding(.top, 6)
                                    Text(item)
                                        .font(.system(size: 13, design: .rounded))
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(20)
        .frame(width: 300, height: 360)
        .glassBackgroundEffect()
    }
}

// MARK: - RegionDetail model

struct RegionDetail {
    let title:       String
    let subtitle:    String
    let icon:        String
    let color:       Color
    let metricValue: String
    let metricUnit:  String
    let trend:       String
    let trendUp:     Bool
    let sections:    [DetailSection]
}

struct DetailSection: Identifiable {
    let id    = UUID()
    let title: String
    let items: [String]
}

// MARK: - Per-region data

extension BodyRegion {
    var detail: RegionDetail {
        switch self {

        case .head:
            return RegionDetail(
                title: "Head", subtitle: "Mental clarity & tension",
                icon: "brain.head.profile", color: .yellow,
                metricValue: "84", metricUnit: "/ 100",
                trend: "+3 from yesterday", trendUp: true,
                sections: [
                    DetailSection(title: "Today", items: [
                        "Mild tension headache at 2pm",
                        "Screen time: 6.4 hrs — above average",
                        "Last migraine: 12 days ago"
                    ]),
                    DetailSection(title: "Tips", items: [
                        "Take a 10 min screen break every hour",
                        "Stay hydrated — aim for 2.5L today",
                        "Try 4-7-8 breathing before bed"
                    ])
                ]
            )

        case .neck:
            return RegionDetail(
                title: "Neck", subtitle: "Posture & mobility",
                icon: "figure.stand", color: .teal,
                metricValue: "61", metricUnit: "/ 100",
                trend: "-5 from yesterday", trendUp: false,
                sections: [
                    DetailSection(title: "Today", items: [
                        "Forward head posture detected at desk",
                        "Stiffness reported this morning",
                        "No movement breaks in last 3 hrs"
                    ]),
                    DetailSection(title: "Exercises", items: [
                        "Roll shoulders back every 30 mins",
                        "Raise monitor to eye level",
                        "Chin tucks: 3 sets of 10 reps"
                    ])
                ]
            )

        case .chest, .upperBack:
            return RegionDetail(
                title: "Heart", subtitle: "Cardiovascular health",
                icon: "heart.fill", color: .red,
                metricValue: "72", metricUnit: "BPM",
                trend: "Resting — normal range", trendUp: true,
                sections: [
                    DetailSection(title: "Today's Readings", items: [
                        "Resting HR: 72 BPM",
                        "Peak HR: 141 BPM during workout",
                        "HRV: 58ms — good recovery",
                        "Blood oxygen: 98%"
                    ]),
                    DetailSection(title: "Recommendations", items: [
                        "HR is in a healthy resting range",
                        "HRV suggests good recovery today",
                        "Stay consistent with cardio 3x/week"
                    ])
                ]
            )

        case .lowerBack:
            return RegionDetail(
                title: "Lower Back", subtitle: "Pain & mobility tracking",
                icon: "figure.walk", color: .orange,
                metricValue: "3", metricUnit: "/ 10 pain",
                trend: "Mild — improving", trendUp: true,
                sections: [
                    DetailSection(title: "Today", items: [
                        "Dull ache after sitting 2+ hrs",
                        "Pain onset: 11am",
                        "No radiation to legs reported"
                    ]),
                    DetailSection(title: "Exercises", items: [
                        "Cat-cow stretch: 2 mins morning & night",
                        "Child's pose: hold 30 secs, 3x",
                        "Hip flexor stretch: 45 secs each side",
                        "Stand up every 45 mins"
                    ])
                ]
            )

        case .leftShoulder, .rightShoulder:
            return RegionDetail(
                title: "Shoulders", subtitle: "Mobility & strength",
                icon: "figure.arms.open", color: .blue,
                metricValue: "78", metricUnit: "/ 100",
                trend: "+2 this week", trendUp: true,
                sections: [
                    DetailSection(title: "Today", items: [
                        "Mild tightness in left shoulder",
                        "Full range of motion maintained",
                        "Last physio: 5 days ago"
                    ]),
                    DetailSection(title: "Exercises", items: [
                        "Arm circles: 20 forward, 20 backward",
                        "Cross-body stretch: 30 secs each",
                        "Band pull-aparts: 3 sets of 15"
                    ])
                ]
            )

        case .leftElbow, .rightElbow:
            return RegionDetail(
                title: "Elbows", subtitle: "Joint health",
                icon: "figure.flexibility", color: .cyan,
                metricValue: "Low", metricUnit: "inflammation",
                trend: "No swelling detected", trendUp: true,
                sections: [
                    DetailSection(title: "Today", items: [
                        "No pain reported today",
                        "Tennis elbow risk: low",
                        "Grip strength: normal"
                    ]),
                    DetailSection(title: "Tips", items: [
                        "Warm up before lifting",
                        "Avoid repetitive gripping",
                        "Ice after intense activity if needed"
                    ])
                ]
            )

        case .leftWrist, .rightWrist:
            return RegionDetail(
                title: "Wrists", subtitle: "Strain & flexibility",
                icon: "hand.raised.fill", color: .mint,
                metricValue: "2", metricUnit: "/ 10 strain",
                trend: "Minimal — healthy", trendUp: true,
                sections: [
                    DetailSection(title: "Today", items: [
                        "Typing time: 4.2 hrs today",
                        "No pain or numbness reported",
                        "Carpal tunnel risk: low"
                    ]),
                    DetailSection(title: "Exercises", items: [
                        "Wrist circles: 10 reps each way",
                        "Prayer stretch: hold 20 secs, 3x",
                        "Keep wrists neutral while typing"
                    ])
                ]
            )

        case .abdomen:
            return RegionDetail(
                title: "Abdomen", subtitle: "Gut health & nutrition",
                icon: "fork.knife", color: .green,
                metricValue: "1,840", metricUnit: "kcal",
                trend: "On track today", trendUp: true,
                sections: [
                    DetailSection(title: "Today", items: [
                        "Calories consumed: 1,840 kcal",
                        "Water intake: 1.8L — slightly low",
                        "Last meal: 1.5 hrs ago",
                        "No bloating reported"
                    ]),
                    DetailSection(title: "Tips", items: [
                        "Drink 700ml more water today",
                        "Add fibre to your next meal",
                        "Avoid eating 2 hrs before sleep"
                    ])
                ]
            )

        case .leftHip, .rightHip:
            return RegionDetail(
                title: "Hips", subtitle: "Flexibility & gait",
                icon: "figure.run", color: .indigo,
                metricValue: "6,240", metricUnit: "steps",
                trend: "Stable this week", trendUp: true,
                sections: [
                    DetailSection(title: "Today", items: [
                        "Steps: 6,240 — below 8k goal",
                        "Hip tightness after sitting: mild",
                        "Gait pattern: normal"
                    ]),
                    DetailSection(title: "Exercises", items: [
                        "Pigeon pose: 60 secs each side",
                        "Hip flexor lunge: 3x each leg",
                        "Glute bridges: 3 sets of 15",
                        "Aim for 8,000 steps today"
                    ])
                ]
            )

        case .leftKnee, .rightKnee:
            return RegionDetail(
                title: "Knees", subtitle: "Joint load & stability",
                icon: "figure.walk.motion", color: .purple,
                metricValue: "Moderate", metricUnit: "load",
                trend: "Within safe range", trendUp: true,
                sections: [
                    DetailSection(title: "Today", items: [
                        "Mild clicking in left knee this morning",
                        "No swelling observed",
                        "Last run: 2 days ago — 5.2km"
                    ]),
                    DetailSection(title: "Exercises", items: [
                        "Quad sets: 3 sets of 15 reps",
                        "Straight leg raises: 3 sets of 12",
                        "Avoid deep squats if pain flares",
                        "Ice 10 mins after activity if sore"
                    ])
                ]
            )

        case .leftAnkle, .rightAnkle:
            return RegionDetail(
                title: "Ankles & Feet", subtitle: "Stability & mobility",
                icon: "shoeprints.fill", color: .brown,
                metricValue: "82", metricUnit: "/ 100",
                trend: "+4 from last week", trendUp: true,
                sections: [
                    DetailSection(title: "Today", items: [
                        "Steps: 6,240",
                        "No ankle pain reported",
                        "Footwear: supportive trainers"
                    ]),
                    DetailSection(title: "Exercises", items: [
                        "Calf raises: 3 sets of 20",
                        "Ankle circles: 10 each direction",
                        "Single leg balance: 30 secs each",
                        "Stretch calves after walking"
                    ])
                ]
            )
        }
    }
}
