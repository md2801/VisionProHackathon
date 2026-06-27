// MARK: - MannequinInteractionSystem.swift.
// Body Health Spatial System
// ADD this as a new Swift file to the p_vision2 target.
//
// Responsibilities:
//   • Load mannequin.usdz OR build a procedural fallback body
//   • Place invisible hit-proxy spheres at 18 anatomical positions
//   • Handle SpatialTapGesture → map entity to BodyRegion → update AppModel
//   • Apply / remove emissive glow highlight on selected region
// MARK: - MannequinInteractionSystem.swift

import RealityKit
import SwiftUI

struct RegionComponent: Component {
    var regionName: String
}

@MainActor
enum MannequinInteractionSystem {

    static func setupMannequin(
        in content: RealityViewContent,
        appModel: AppModel
    ) async {
        let anchor = AnchorEntity(.head, trackingMode: .once)
        anchor.name     = "MannequinAnchor"
        anchor.position = SIMD3(0, -0.9, -1.5)
        content.add(anchor)

        let mannequin: Entity
        do {
            let model = try await ModelEntity.loadModel(named: "mannequin")
            model.scale = SIMD3(repeating: 0.012)
            mannequin = model
        } catch {
            print("[Mannequin] Using procedural fallback: \(error.localizedDescription)")
            mannequin = buildProceduralMannequin()
        }

        mannequin.name = "Mannequin"
        anchor.addChild(mannequin)
        appModel.mannequinEntity = mannequin
    }

    static func handleTap(on entity: Entity, appModel: AppModel) {
        var node: Entity? = entity
        while let current = node {
            if let component = current.components[RegionComponent.self],
               let region = BodyRegion(rawValue: component.regionName) {
                appModel.selectRegion(region, entity: current)
                return
            }
            node = current.parent
        }
    }

    // MARK: - Procedural Mannequin
    // No separate hit proxies — RegionComponent lives directly on each
    // visible mesh. Collision shapes are generated on the same entity.
    // This eliminates all black holes.

    private static func buildProceduralMannequin() -> Entity {
        let root = Entity()
        root.name = "Mannequin"

        // ── HEAD ──────────────────────────────────────────────────────────
        add(root, name: "head",
            mesh: .generateSphere(radius: 0.105),
            pos:  SIMD3(0, 0.90, 0),
            region: .head)

        // ── NECK ──────────────────────────────────────────────────────────
        add(root, name: "neck",
            mesh: .generateCylinder(height: 0.09, radius: 0.040),
            pos:  SIMD3(0, 0.800, 0),
            region: .neck)

        // ── SHOULDER BAR ──────────────────────────────────────────────────
        add(root, name: "shoulderBar",
            mesh: .generateBox(width: 0.44, height: 0.068, depth: 0.17,
                               cornerRadius: 0.034),
            pos:  SIMD3(0, 0.728, 0),
            region: .chest)

        // ── CHEST ─────────────────────────────────────────────────────────
        add(root, name: "chest",
            mesh: .generateBox(width: 0.34, height: 0.22, depth: 0.17,
                               cornerRadius: 0.04),
            pos:  SIMD3(0, 0.582, 0),
            region: .chest)

        // ── ABDOMEN ───────────────────────────────────────────────────────
        add(root, name: "abdomen",
            mesh: .generateBox(width: 0.29, height: 0.18, depth: 0.15,
                               cornerRadius: 0.04),
            pos:  SIMD3(0, 0.378, 0),
            region: .abdomen)

        // ── PELVIS ────────────────────────────────────────────────────────
        add(root, name: "pelvis",
            mesh: .generateBox(width: 0.31, height: 0.14, depth: 0.16,
                               cornerRadius: 0.04),
            pos:  SIMD3(0, 0.225, 0),
            region: .abdomen)

        // ── LEFT ARM ──────────────────────────────────────────────────────

        add(root, name: "lShoulderBall",
            mesh: .generateSphere(radius: 0.054),
            pos:  SIMD3(0.248, 0.718, 0),
            region: .leftShoulder)

        add(root, name: "lUpperArm",
            mesh: .generateCylinder(height: 0.27, radius: 0.047),
            pos:  SIMD3(0.290, 0.558, 0),
            rot:  simd_quatf(angle: 0.18, axis: SIMD3(0, 0, 1)),
            region: .leftShoulder)

        add(root, name: "lElbowBall",
            mesh: .generateSphere(radius: 0.042),
            pos:  SIMD3(0.330, 0.392, 0),
            region: .leftElbow)

        add(root, name: "lLowerArm",
            mesh: .generateCylinder(height: 0.25, radius: 0.036),
            pos:  SIMD3(0.342, 0.242, 0),
            region: .leftElbow)

        add(root, name: "lWristBall",
            mesh: .generateSphere(radius: 0.032),
            pos:  SIMD3(0.350, 0.108, 0),
            region: .leftWrist)

        add(root, name: "lHand",
            mesh: .generateBox(width: 0.070, height: 0.092, depth: 0.038,
                               cornerRadius: 0.016),
            pos:  SIMD3(0.352, 0.020, 0),
            region: .leftWrist)

        // ── RIGHT ARM ─────────────────────────────────────────────────────

        add(root, name: "rShoulderBall",
            mesh: .generateSphere(radius: 0.054),
            pos:  SIMD3(-0.248, 0.718, 0),
            region: .rightShoulder)

        add(root, name: "rUpperArm",
            mesh: .generateCylinder(height: 0.27, radius: 0.047),
            pos:  SIMD3(-0.290, 0.558, 0),
            rot:  simd_quatf(angle: -0.18, axis: SIMD3(0, 0, 1)),
            region: .rightShoulder)

        add(root, name: "rElbowBall",
            mesh: .generateSphere(radius: 0.042),
            pos:  SIMD3(-0.330, 0.392, 0),
            region: .rightElbow)

        add(root, name: "rLowerArm",
            mesh: .generateCylinder(height: 0.25, radius: 0.036),
            pos:  SIMD3(-0.342, 0.242, 0),
            region: .rightElbow)

        add(root, name: "rWristBall",
            mesh: .generateSphere(radius: 0.032),
            pos:  SIMD3(-0.350, 0.108, 0),
            region: .rightWrist)

        add(root, name: "rHand",
            mesh: .generateBox(width: 0.070, height: 0.092, depth: 0.038,
                               cornerRadius: 0.016),
            pos:  SIMD3(-0.352, 0.020, 0),
            region: .rightWrist)

        // ── LEFT LEG ──────────────────────────────────────────────────────

        add(root, name: "lHipBall",
            mesh: .generateSphere(radius: 0.056),
            pos:  SIMD3(0.112, 0.158, 0),
            region: .leftHip)

        add(root, name: "lUpperLeg",
            mesh: .generateCylinder(height: 0.37, radius: 0.068),
            pos:  SIMD3(0.112, -0.030, 0),
            region: .leftHip)

        add(root, name: "lKneeBall",
            mesh: .generateSphere(radius: 0.052),
            pos:  SIMD3(0.112, -0.222, 0),
            region: .leftKnee)

        add(root, name: "lLowerLeg",
            mesh: .generateCylinder(height: 0.34, radius: 0.045),
            pos:  SIMD3(0.112, -0.395, 0),
            region: .leftKnee)

        add(root, name: "lAnkleBall",
            mesh: .generateSphere(radius: 0.036),
            pos:  SIMD3(0.112, -0.572, 0),
            region: .leftAnkle)

        add(root, name: "lFoot",
            mesh: .generateBox(width: 0.082, height: 0.048, depth: 0.158,
                               cornerRadius: 0.018),
            pos:  SIMD3(0.112, -0.594, 0.050),
            region: .leftAnkle)

        // ── RIGHT LEG ─────────────────────────────────────────────────────

        add(root, name: "rHipBall",
            mesh: .generateSphere(radius: 0.056),
            pos:  SIMD3(-0.112, 0.158, 0),
            region: .rightHip)

        add(root, name: "rUpperLeg",
            mesh: .generateCylinder(height: 0.37, radius: 0.068),
            pos:  SIMD3(-0.112, -0.030, 0),
            region: .rightHip)

        add(root, name: "rKneeBall",
            mesh: .generateSphere(radius: 0.052),
            pos:  SIMD3(-0.112, -0.222, 0),
            region: .rightKnee)

        add(root, name: "rLowerLeg",
            mesh: .generateCylinder(height: 0.34, radius: 0.045),
            pos:  SIMD3(-0.112, -0.395, 0),
            region: .rightKnee)

        add(root, name: "rAnkleBall",
            mesh: .generateSphere(radius: 0.036),
            pos:  SIMD3(-0.112, -0.572, 0),
            region: .rightAnkle)

        add(root, name: "rFoot",
            mesh: .generateBox(width: 0.082, height: 0.048, depth: 0.158,
                               cornerRadius: 0.018),
            pos:  SIMD3(-0.112, -0.594, 0.050),
            region: .rightAnkle)

        return root
    }

    // MARK: - Segment builder
    // Visual mesh + collision + input + hover + region tag — all on ONE entity.
    // No separate OcclusionMaterial proxies = no black holes.

    private static func add(
        _ root: Entity,
        name:   String,
        mesh:   MeshResource,
        pos:    SIMD3<Float>,
        rot:    simd_quatf = simd_quatf(ix: 0, iy: 0, iz: 0, r: 1),
        region: BodyRegion
    ) {
        let mat: PhysicallyBasedMaterial = .bodyMaterial()
        let e = ModelEntity(mesh: mesh, materials: [mat])
        e.name        = name
        e.position    = pos
        e.orientation = rot

        // Collision shape on the same entity — no separate proxy needed
        e.generateCollisionShapes(recursive: false)

        // Indirect pinch input (standard Vision Pro interaction)
        e.components.set(InputTargetComponent(allowedInputTypes: .indirect))

        // HoverEffectComponent = built-in visionOS eye-tracking highlight
        // When you look at a segment it automatically brightens — no code needed
        e.components.set(HoverEffectComponent())

        // Tag so handleTap knows which body region was touched
        e.components.set(RegionComponent(regionName: region.rawValue))

        root.addChild(e)
    }
}

// MARK: - Glow (applied on pinch selection)

extension Entity {

    func applyGlowEffect(color: UIColor) {
        var queue: [Entity] = [self]
        while !queue.isEmpty {
            let node = queue.removeFirst()
            if let model = node as? ModelEntity {
                var glow = PhysicallyBasedMaterial()
                glow.emissiveColor     = .init(color: color)
                glow.emissiveIntensity = 1.6
                glow.baseColor         = .init(tint: color.withAlphaComponent(0.35))
                let m: PhysicallyBasedMaterial = glow
                model.model?.materials = (model.model?.materials ?? []).map { _ in m }
            }
            queue.append(contentsOf: node.children)
        }
    }

    func removeGlowEffect() {
        var queue: [Entity] = [self]
        while !queue.isEmpty {
            let node = queue.removeFirst()
            if let model = node as? ModelEntity {
                let restored: PhysicallyBasedMaterial = .bodyMaterial()
                model.model?.materials = (model.model?.materials ?? []).map { _ in restored }
            }
            queue.append(contentsOf: node.children)
        }
    }
}

// MARK: - Material

extension PhysicallyBasedMaterial {
    static func bodyMaterial() -> PhysicallyBasedMaterial {
        var mat = PhysicallyBasedMaterial()
        mat.baseColor = .init(tint: UIColor(red: 0.86, green: 0.73, blue: 0.58, alpha: 1.0))
        mat.roughness = .init(floatLiteral: 0.70)
        mat.metallic  = .init(floatLiteral: 0.0)
        return mat
    }
}
