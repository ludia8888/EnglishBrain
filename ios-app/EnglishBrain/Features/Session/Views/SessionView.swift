//
//  SessionView.swift
//  EnglishBrain
//
//  Created by Claude on 10/4/25.
//

import SwiftUI
import EnglishBrainAPI

struct SessionView: View {
    @StateObject private var viewModel = SessionViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.ebBackground.ignoresSafeArea()

            if viewModel.isLoading {
                ProgressView("문제 불러오는 중...")
                    .scaleEffect(1.2)
            } else if let session = viewModel.stateManager.session {
                mainSessionView(session)
            } else {
                errorOrStartView
            }

            // Checkpoint modal
            if viewModel.showCheckpoint {
                checkpointModal
            }

            // Completion modal
            if viewModel.showCompletion {
                completionModal
            }

            // Brain Burst animation
            if viewModel.showBrainBurst {
                brainBurstOverlay
            }
        }
        .onAppear {
            viewModel.startSession()
        }
    }

    // MARK: - Main Session View

    private func mainSessionView(_ session: Session) -> some View {
        VStack(spacing: 0) {
            // Header
            sessionHeader

            Spacer()

            // Content area
            if let item = viewModel.stateManager.currentItem {
                sessionItemView(item)
            }

            Spacer()
        }
    }

    private var sessionHeader: some View {
        VStack(spacing: 12) {
            HStack {
                // Close button
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.ebTextSecondary)
                }

                Spacer()

                // Phase indicator
                if let phase = viewModel.stateManager.currentPhase {
                    phaseIndicator(phase)
                }

                Spacer()

                // Brain Burst indicator
                if let burst = viewModel.brainBurst, burst.active {
                    HStack(spacing: 4) {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 14))
                        Text("×\(String(format: "%.1f", burst.multiplier))")
                            .font(.ebLabel)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.yellow)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.yellow.opacity(0.2))
                    )
                }

                Spacer()

                // Combo indicator
                if viewModel.stateManager.combo > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 14))
                        Text("\(viewModel.stateManager.combo)")
                            .font(.ebLabel)
                    }
                    .foregroundColor(.ebWarning)
                }
            }
            .padding(.horizontal)
            .padding(.top, 16)

            // Progress bar
            if let phase = viewModel.stateManager.currentPhase {
                GeometryReader { geometry in
                    let totalItems = phase.itemIds.count
                    let currentItem = viewModel.stateManager.currentItemIndex + 1
                    let progress = Double(currentItem) / Double(totalItems)

                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.ebDivider)
                            .frame(height: 6)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(phaseColor(phase.phaseType))
                            .frame(width: geometry.size.width * progress, height: 6)
                            .animation(.easeInOut, value: progress)
                    }
                }
                .frame(height: 6)
                .padding(.horizontal)
            }
        }
    }

    private func phaseIndicator(_ phase: SessionPhase) -> some View {
        HStack(spacing: 6) {
            Image(systemName: phaseIcon(phase.phaseType))
                .font(.system(size: 14))
            Text(phase.label)
                .font(.ebLabel)
        }
        .foregroundColor(phaseColor(phase.phaseType))
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(phaseColor(phase.phaseType).opacity(0.1))
        )
    }

    private func sessionItemView(_ item: SessionItem) -> some View {
        VStack(spacing: 32) {
            // Prompt
            VStack(spacing: 12) {
                Text("이 문장을 영어로 만들어볼까요?")
                    .font(.ebLabel)
                    .foregroundColor(.ebTextSecondary)

                Text(item.prompt.ko)
                    .font(.ebH3)
                    .foregroundColor(.ebTextPrimary)
                    .multilineTextAlignment(.center)
            }
            .padding()

            // Slots
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(viewModel.slots.enumerated()), id: \.offset) { index, slot in
                        sessionSlotView(slot: slot, index: index)
                    }
                }
                .padding(.horizontal)
            }

            // Tokens
            VStack(spacing: 16) {
                Text("사용할 단어")
                    .font(.ebLabel)
                    .foregroundColor(.ebTextSecondary)

                FlowLayout(spacing: 12) {
                    ForEach(viewModel.availableTokens) { token in
                        sessionTokenView(token: token)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.ebSurface)
            )
            .padding(.horizontal)

            // Hint button
            if let phase = viewModel.stateManager.currentPhase,
               let hintBudget = phase.hintBudget {
                Button(action: viewModel.useHint) {
                    HStack(spacing: 8) {
                        Image(systemName: "lightbulb.fill")
                        Text("힌트 (\(hintBudget - viewModel.stateManager.attemptState.hintsUsed) 남음)")
                    }
                    .font(.ebLabel)
                    .foregroundColor(viewModel.stateManager.attemptState.hintsUsed < hintBudget ? .ebInfo : .ebTextDisabled)
                }
                .disabled(viewModel.stateManager.attemptState.hintsUsed >= hintBudget)
            }
        }
    }

    private func sessionSlotView(slot: SessionViewModel.SlotItem, index: Int) -> some View {
        Button(action: {
            if slot.token != nil {
                viewModel.removeTokenFromSlot(index)
            } else if viewModel.selectedTokenId != nil {
                viewModel.placeTokenInSlot(index)
            }
        }) {
            RoundedRectangle(cornerRadius: 12)
                .fill(slot.token != nil ? Color.ebSurface : Color.ebSurface.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(
                            Color.ebPrimary,
                            style: StrokeStyle(lineWidth: 2, dash: slot.token != nil ? [] : [5])
                        )
                )
                .overlay(
                    Group {
                        if let token = slot.token {
                            Text(token.text)
                                .font(.ebBody)
                                .foregroundColor(.ebTextPrimary)
                        } else {
                            Text(slot.slotType)
                                .font(.ebCaption)
                                .foregroundColor(.ebTextDisabled)
                        }
                    }
                )
                .frame(minWidth: 80)
                .frame(height: 50)
        }
        .buttonStyle(.plain)
    }

    private func sessionTokenView(token: SessionViewModel.TokenDragItem) -> some View {
        Button(action: {
            viewModel.selectToken(token.id)
        }) {
            Text(token.text)
                .font(.ebBody)
                .foregroundColor(.ebTextPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(viewModel.selectedTokenId == token.id ? Color.ebPrimary.opacity(0.3) : Color.ebPrimaryLight.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(
                                    viewModel.selectedTokenId == token.id ? Color.ebPrimary : Color.clear,
                                    lineWidth: 2
                                )
                        )
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Checkpoint Modal

    private var checkpointModal: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.ebSuccess)

                if let phase = viewModel.stateManager.currentPhase {
                    let completionText: String = {
                        switch phase.phaseType {
                        case .warmUp: return "예열 완료!"
                        case .focus: return "집중 구간 돌파!"
                        case .coolDown: return "마무리 완벽!"
                        default: return "\(phase.label) 완료!"
                        }
                    }()
                    Text(completionText)
                        .font(.ebH2)
                        .foregroundColor(.white)
                }

                VStack(spacing: 12) {
                    Text("정답률 \(Int(Double(viewModel.stateManager.totalCorrect) / Double(viewModel.stateManager.totalAttempts) * 100))%")
                        .font(.ebBodyLarge)
                        .foregroundColor(.white)

                    Text("연속 정답 최고 \(viewModel.stateManager.combo)개")
                        .font(.ebBody)
                        .foregroundColor(.white.opacity(0.8))
                }

                PrimaryButton(title: "계속하기", action: viewModel.completePhaseCheckpoint)
                    .frame(width: 200)
            }
            .padding(40)
        }
    }

    // MARK: - Completion Modal

    private var completionModal: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Image(systemName: "star.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.ebWarning)

                Text("오늘 세션 완료!")
                    .font(.ebH2)
                    .foregroundColor(.white)

                Text("오늘도 영어 회로가 더 단단해졌어요")
                    .font(.ebBodyLarge)
                    .foregroundColor(.white)

                VStack(spacing: 12) {
                    PrimaryButton(title: "홈으로", action: { dismiss() })
                        .frame(width: 200)

                    Button(action: {
                        // TODO: Launch review with weak patterns from this session
                        dismiss()
                    }) {
                        Text("약점 바로 복습하기")
                            .font(.ebBody)
                            .foregroundColor(.ebPrimary)
                            .padding(.vertical, 12)
                    }
                }
            }
            .padding(40)
        }
    }

    // MARK: - Error View

    private var errorOrStartView: some View {
        VStack(spacing: 16) {
            if let errorMessage = viewModel.errorMessage {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 48))
                    .foregroundColor(.ebError)

                Text("세션을 시작할 수 없어요")
                    .font(.ebH4)
                    .foregroundColor(.ebTextPrimary)

                Text(errorMessage)
                    .font(.ebBody)
                    .foregroundColor(.ebTextSecondary)
                    .multilineTextAlignment(.center)

                PrimaryButton(title: "다시 시도", action: { viewModel.startSession() })
                    .frame(width: 200)
            }
        }
        .padding()
    }

    // MARK: - Brain Burst Overlay

    private var brainBurstOverlay: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                if let burst = viewModel.brainBurst {
                    BrainBurstAnimationView(multiplier: burst.multiplier)
                        .frame(height: 300)

                    VStack(spacing: 12) {
                        Text("Brain Burst 활성화!")
                            .font(.system(size: 36, weight: .black))
                            .foregroundColor(.white)

                        Text("이번 문장은 점수 2배 찬스!")
                            .font(.ebH4)
                            .foregroundColor(.white.opacity(0.9))

                        if let sessionsUntil = burst.sessionsUntilActivation, sessionsUntil > 0 {
                            Text("\(sessionsUntil)번 더 하면 또 찾아올게요")
                                .font(.ebBody)
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.top, 8)
                        }
                    }

                    PrimaryButton(
                        title: "시작하기",
                        action: {
                            withAnimation {
                                viewModel.showBrainBurst = false
                            }
                        }
                    )
                    .padding(.horizontal, 32)
                    .padding(.top, 16)
                }
            }
        }
        .transition(.opacity)
    }

    // MARK: - Helpers

    private func phaseIcon(_ type: SessionPhase.PhaseType) -> String {
        switch type {
        case .warmUp: return "sunrise.fill"
        case .focus: return "target"
        case .coolDown: return "moon.fill"
        case .review: return "arrow.counterclockwise"
        case .challenge: return "bolt.fill"
        }
    }

    private func phaseColor(_ type: SessionPhase.PhaseType) -> Color {
        switch type {
        case .warmUp: return .ebWarning
        case .focus: return .ebPrimary
        case .coolDown: return .ebInfo
        case .review: return .ebSuccess
        case .challenge: return .ebError
        }
    }
}

#Preview {
    SessionView()
}
