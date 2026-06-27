// MARK: - ImmersiveView.swift
import SwiftUI
import RealityKit

struct ImmersiveView: View {

    @EnvironmentObject private var appModel: AppModel

    private let bodyDetailID = "bodyDetail"
    private let painInputID  = "painInput"
    private let aiResponseID = "aiResponse"

    var body: some View {
        RealityView { content, attachments in

            await MannequinInteractionSystem.setupMannequin(
                in: content,
                appModel: appModel
            )

        } update: { content, attachments in

            guard let region    = appModel.selectedBodyRegion,
                  let mannequin = appModel.mannequinEntity else { return }

            if appModel.showBodyDetail,
               let detailPanel = attachments.entity(for: bodyDetailID) {
                AttachmentManager.positionPanel(
                    detailPanel,
                    relativeTo: mannequin,
                    offset: region.panelOffset
                )
            }

            if appModel.showPainInput,
               let painPanel = attachments.entity(for: painInputID) {
                AttachmentManager.positionPanel(
                    painPanel,
                    relativeTo: mannequin,
                    offset: region.panelOffset
                )
            }

            if appModel.showAIResponse,
               let aiPanel = attachments.entity(for: aiResponseID) {
                AttachmentManager.positionPanel(
                    aiPanel,
                    relativeTo: mannequin,
                    offset: region.panelOffset
                )
            }

        } attachments: {

            // MARK: Body Detail Card — shown on first tap
            Attachment(id: bodyDetailID) {
                if appModel.showBodyDetail,
                   let region = appModel.selectedBodyRegion {
                    BodyDetailView(
                        region: region,
                        onDismiss: { appModel.dismiss() }
                    )
                    .transition(
                        .asymmetric(
                            insertion: .scale(scale: 0.88).combined(with: .opacity),
                            removal:   .scale(scale: 0.88).combined(with: .opacity)
                        )
                    )
                    .animation(
                        .spring(response: 0.42, dampingFraction: 0.76),
                        value: appModel.showBodyDetail
                    )
                }
            }

            // MARK: Pain Input Panel
            Attachment(id: painInputID) {
                if appModel.showPainInput, let log = appModel.currentPainLog {
                    PainInputView(
                        painLog: log,
                        onSubmit:  { appModel.submitPainLog($0) },
                        onDismiss: { appModel.dismiss() }
                    )
                    .transition(
                        .asymmetric(
                            insertion: .scale(scale: 0.88).combined(with: .opacity),
                            removal:   .scale(scale: 0.88).combined(with: .opacity)
                        )
                    )
                    .animation(
                        .spring(response: 0.42, dampingFraction: 0.76),
                        value: appModel.showPainInput
                    )
                }
            }

            // MARK: AI Response Panel
            Attachment(id: aiResponseID) {
                if appModel.showAIResponse {
                    AIResponseView(
                        region:      appModel.selectedBodyRegion ?? .chest,
                        painLevel:   appModel.currentPainLog?.painLevel ?? 5,
                        suggestions: appModel.aiSuggestions,
                        onDismiss:   { appModel.dismiss() }
                    )
                    .transition(
                        .asymmetric(
                            insertion: .scale(scale: 0.88).combined(with: .opacity),
                            removal:   .scale(scale: 0.88).combined(with: .opacity)
                        )
                    )
                    .animation(
                        .spring(response: 0.42, dampingFraction: 0.76),
                        value: appModel.showAIResponse
                    )
                }
            }
        }
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    MannequinInteractionSystem.handleTap(
                        on: value.entity,
                        appModel: appModel
                    )
                }
        )
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environmentObject(AppModel())
}
