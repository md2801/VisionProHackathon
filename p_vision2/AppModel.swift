// MARK: - AppModel.swift.
import SwiftUI
import RealityKit
import Combine

@MainActor
final class AppModel: ObservableObject {

    let immersiveSpaceID = "ImmersiveSpace"

    enum ImmersiveSpaceState {
        case closed, inTransition, open
    }

    @Published var immersiveSpaceState: ImmersiveSpaceState = .closed

    // Interaction state
    @Published var selectedBodyRegion: BodyRegion?
    @Published var showBodyDetail:  Bool = false
    @Published var showPainInput:   Bool = false
    @Published var showAIResponse:  Bool = false
    @Published var currentPainLog:  PainLog?
    @Published var aiSuggestions:   [AISuggestion] = []

    // RealityKit references
    var mannequinEntity:   Entity?
    var highlightedEntity: Entity?

    // MARK: - Region Selection
    // First tap → show body detail card for that region
    func selectRegion(_ region: BodyRegion, entity: Entity?) {
        clearHighlight()
        selectedBodyRegion = region
        highlightedEntity  = entity
        applyHighlight(to: entity)
        currentPainLog     = PainLog(region: region)
        showBodyDetail     = true
        showPainInput      = false
        showAIResponse     = false
    }

    // MARK: - Submit pain log → run mock AI
    func submitPainLog(_ log: PainLog) {
        currentPainLog = log
        aiSuggestions  = AIEngine.generateSuggestion(
            for: log.region.rawValue,
            painLevel: log.painLevel,
            symptoms: log.symptoms
        )
        showBodyDetail = false
        showPainInput  = false
        showAIResponse = true
    }

    // MARK: - Dismiss everything
    func dismiss() {
        clearHighlight()
        showBodyDetail     = false
        showPainInput      = false
        showAIResponse     = false
        selectedBodyRegion = nil
        currentPainLog     = nil
        aiSuggestions      = []
    }

    // MARK: - Highlight helpers
    private func applyHighlight(to entity: Entity?) {
        guard let entity else { return }
        entity.applyGlowEffect(color: UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0))
    }

    private func clearHighlight() {
        highlightedEntity?.removeGlowEffect()
        highlightedEntity = nil
    }
}

// MARK: - BodyRegion

enum BodyRegion: String, CaseIterable, Identifiable {
    var id: String { rawValue }

    case head           = "head"
    case neck           = "neck"
    case leftShoulder   = "left_shoulder"
    case rightShoulder  = "right_shoulder"
    case chest          = "chest"
    case upperBack      = "upper_back"
    case lowerBack      = "lower_back"
    case leftElbow      = "left_elbow"
    case rightElbow     = "right_elbow"
    case leftWrist      = "left_wrist"
    case rightWrist     = "right_wrist"
    case abdomen        = "abdomen"
    case leftHip        = "left_hip"
    case rightHip       = "right_hip"
    case leftKnee       = "left_knee"
    case rightKnee      = "right_knee"
    case leftAnkle      = "left_ankle"
    case rightAnkle     = "right_ankle"

    var displayName: String {
        switch self {
        case .head:          return "Head"
        case .neck:          return "Neck"
        case .leftShoulder:  return "Left Shoulder"
        case .rightShoulder: return "Right Shoulder"
        case .chest:         return "Chest"
        case .upperBack:     return "Upper Back"
        case .lowerBack:     return "Lower Back"
        case .leftElbow:     return "Left Elbow"
        case .rightElbow:    return "Right Elbow"
        case .leftWrist:     return "Left Wrist"
        case .rightWrist:    return "Right Wrist"
        case .abdomen:       return "Abdomen"
        case .leftHip:       return "Left Hip"
        case .rightHip:      return "Right Hip"
        case .leftKnee:      return "Left Knee"
        case .rightKnee:     return "Right Knee"
        case .leftAnkle:     return "Left Ankle"
        case .rightAnkle:    return "Right Ankle"
        }
    }

    var panelOffset: SIMD3<Float> {
        switch self {
        case .head:          return SIMD3( 0.35,  0.90,  0.08)
        case .neck:          return SIMD3( 0.35,  0.76,  0.08)
        case .leftShoulder:  return SIMD3( 0.52,  0.62,  0.08)
        case .rightShoulder: return SIMD3(-0.52,  0.62,  0.08)
        case .chest:         return SIMD3( 0.42,  0.48,  0.08)
        case .upperBack:     return SIMD3(-0.42,  0.55,  0.08)
        case .lowerBack:     return SIMD3(-0.42,  0.28,  0.08)
        case .leftElbow:     return SIMD3( 0.58,  0.34,  0.08)
        case .rightElbow:    return SIMD3(-0.58,  0.34,  0.08)
        case .leftWrist:     return SIMD3( 0.62,  0.08,  0.08)
        case .rightWrist:    return SIMD3(-0.62,  0.08,  0.08)
        case .abdomen:       return SIMD3( 0.42,  0.20,  0.08)
        case .leftHip:       return SIMD3( 0.46, -0.08,  0.08)
        case .rightHip:      return SIMD3(-0.46, -0.08,  0.08)
        case .leftKnee:      return SIMD3( 0.42, -0.40,  0.08)
        case .rightKnee:     return SIMD3(-0.42, -0.40,  0.08)
        case .leftAnkle:     return SIMD3( 0.38, -0.72,  0.08)
        case .rightAnkle:    return SIMD3(-0.38, -0.72,  0.08)
        }
    }
}

// MARK: - PainLog

struct PainLog {
    var region:    BodyRegion
    var painLevel: Int    = 5
    var symptoms:  String = ""
    var timestamp: Date   = Date()
}

// MARK: - AISuggestion

struct AISuggestion: Identifiable {
    let id       = UUID()
    let icon:    String
    let title:   String
    let detail:  String
    let category: Category

    enum Category {
        case diagnosis, action, warning, lifestyle

        var color: Color {
            switch self {
            case .diagnosis: return .blue
            case .action:    return .green
            case .warning:   return .orange
            case .lifestyle: return .purple
            }
        }

        var systemImage: String {
            switch self {
            case .diagnosis: return "stethoscope"
            case .action:    return "figure.walk"
            case .warning:   return "exclamationmark.triangle.fill"
            case .lifestyle: return "heart.fill"
            }
        }
    }
}
