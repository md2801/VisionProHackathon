// MARK: - AttachmentManager.swift

import RealityKit

struct AttachmentManager {

    static func positionPanel(
        _ panel: Entity,
        relativeTo parent: Entity,
        offset: SIMD3<Float>
    ) {
        // Remove from previous parent
        panel.removeFromParent()

        // Attach to mannequin (or any parent entity)
        parent.addChild(panel)

        // Position relative to body part
        panel.position = offset

        // ✅ Proper billboarding (Vision Pro friendly)
        panel.components.set(BillboardComponent())
    }
}
