//
//  LevelTestView.swift
//  EnglishBrain
//
//  Created by Claude on 10/4/25.
//

import SwiftUI

struct LevelTestView: View {
    @StateObject private var viewModel = LevelTestViewModel()
    let onComplete: () -> Void

    var body: some View {
        ZStack {
            Color.ebBackground.ignoresSafeArea()

            VStack(spacing: 24) {
                // Header
                headerView

                // Progress
                progressView

                // Korean sentence
                if let item = viewModel.currentItem {
                    koreanSentenceView(item)
                }

                Spacer()

                // Drop slots
                slotsView

                Spacer()

                // Available tokens
                tokensView

                // Hint button
                hintButton

                Spacer()
            }
            .padding()

            // Feedback overlay
            if viewModel.showFeedback {
                feedbackOverlay
            }

            // Loading overlay
            if viewModel.isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                ProgressView()
                    .scaleEffect(1.5)
            }

            // Error overlay
            if let errorMessage = viewModel.errorMessage {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()

                VStack(spacing: 24) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.ebError)

                    Text("잠깐요")
                        .font(.ebH3)
                        .foregroundColor(.white)

                    Text(errorMessage)
                        .font(.ebBody)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)

                    PrimaryButton(title: "확인", action: {
                        viewModel.errorMessage = nil
                    })
                    .frame(width: 200)
                }
                .padding(32)
            }
        }
        .onAppear {
            // Connect onComplete callback to viewModel
            viewModel.onComplete = onComplete
        }
    }

    // MARK: - Subviews

    private var headerView: some View {
        HStack {
            Text("레벨 테스트")
                .font(.ebH3)
                .foregroundColor(.ebTextPrimary)
            Spacer()
            Text("\(viewModel.currentItemIndex + 1)/\(viewModel.items.count)")
                .font(.ebLabel)
                .foregroundColor(.ebTextSecondary)
        }
    }

    private var progressView: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.ebDivider)
                    .frame(height: 8)

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.ebPrimary)
                    .frame(width: geometry.size.width * viewModel.progress, height: 8)
                    .animation(.easeInOut, value: viewModel.progress)
            }
        }
        .frame(height: 8)
    }

    private func koreanSentenceView(_ item: LevelTestItem) -> some View {
        VStack(spacing: 12) {
            Text("이 문장을 영어 어순으로 만들어볼까요?")
                .font(.ebLabel)
                .foregroundColor(.ebTextSecondary)

            Text(item.koreanSentence)
                .font(.ebH4)
                .foregroundColor(.ebTextPrimary)
                .multilineTextAlignment(.center)

            // Hint text (shown at hint level 1)
            if viewModel.hintLevel.rawValue >= 1 {
                Text("💡 주어 → 동사 → 목적어 순서로 놓아보세요")
                    .font(.ebBodySmall)
                    .foregroundColor(.ebInfo)
                    .transition(.opacity)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.ebSurface)
                .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        )
    }

    private var slotsView: some View {
        HStack(spacing: 12) {
            ForEach(Array(viewModel.slots.enumerated()), id: \.offset) { index, slot in
                SlotView(
                    slot: slot,
                    showLabel: viewModel.hintLevel.rawValue >= 2,
                    showHighlight: viewModel.hintLevel.rawValue >= 3,
                    onTap: {
                        if slot.token != nil {
                            viewModel.removeToken(from: index)
                        }
                    }
                )
                .onDrop(of: [.text], delegate: SlotDropDelegate(
                    slotIndex: index,
                    viewModel: viewModel
                ))
            }
        }
    }

    private var tokensView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("사용할 단어")
                .font(.ebLabel)
                .foregroundColor(.ebTextSecondary)

            FlowLayout(spacing: 12) {
                ForEach(viewModel.availableTokens) { token in
                    TokenView(token: token)
                        .onDrag {
                            NSItemProvider(object: token.id as NSString)
                        }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.ebSurface)
                .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        )
    }

    private var hintButton: some View {
        Button(action: viewModel.useHint) {
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                Text("힌트 보기 (\(viewModel.hintLevel.rawValue)/3)")
            }
            .font(.ebLabel)
            .foregroundColor(viewModel.hintLevel.rawValue < 3 ? .ebPrimary : .ebTextDisabled)
        }
        .disabled(viewModel.hintLevel.rawValue >= 3)
    }

    private var feedbackOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Image(systemName: viewModel.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(viewModel.isCorrect ? .ebSuccess : .ebError)

                Text(viewModel.isCorrect ? "맞았어요!" : "조금만 더 생각해볼까요?")
                    .font(.ebH3)
                    .foregroundColor(.white)

                if viewModel.isCorrect {
                    PrimaryButton(title: "다음", action: viewModel.nextItem)
                        .frame(width: 200)
                } else {
                    HStack(spacing: 16) {
                        PrimaryButton(
                            title: "다시 시도",
                            action: viewModel.retryCurrentItem,
                            style: .secondary
                        )
                        .frame(width: 140)

                        PrimaryButton(
                            title: "힌트가 필요해요",
                            action: {
                                viewModel.showFeedback = false
                                viewModel.useHint()
                            },
                            style: .outline
                        )
                        .frame(width: 160)
                    }
                }
            }
            .padding(32)
        }
        .transition(.opacity)
    }
}

// MARK: - Supporting Views

struct SlotView: View {
    let slot: SlotPosition
    let showLabel: Bool
    let showHighlight: Bool
    let onTap: () -> Void

    private var slotColor: Color {
        switch slot.type {
        case .subject: return .ebSlotSubject
        case .verb: return .ebSlotVerb
        case .object: return .ebSlotObject
        case .modifier: return .ebSlotModifier
        }
    }

    var body: some View {
        VStack(spacing: 4) {
            if showLabel {
                Text(slot.type.rawValue)
                    .font(.ebCaption)
                    .foregroundColor(slotColor)
            }

            RoundedRectangle(cornerRadius: 12)
                .fill(slot.token != nil ? Color.ebSurface : Color.ebSurface.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(
                            showHighlight && slot.token == nil ? slotColor : Color.ebDivider,
                            style: StrokeStyle(lineWidth: showHighlight && slot.token == nil ? 3 : 2, dash: slot.token != nil ? [] : [5])
                        )
                )
                .overlay(
                    Group {
                        if let token = slot.token {
                            Text(token.text)
                                .font(.ebBody)
                                .foregroundColor(.ebTextPrimary)
                                .padding(8)
                        } else {
                            Text(showLabel ? slot.type.rawValue : "")
                                .font(.ebBodySmall)
                                .foregroundColor(.ebTextDisabled)
                        }
                    }
                )
                .frame(minWidth: 80, minHeight: 50)
                .onTapGesture(perform: onTap)
        }
    }
}

struct TokenView: View {
    let token: TokenItem

    var body: some View {
        Text(token.text)
            .font(.ebBody)
            .foregroundColor(.ebTextPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.ebPrimaryLight.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(Color.ebPrimary, lineWidth: 1)
                    )
            )
    }
}

// MARK: - Drag & Drop Delegate

class SlotDropDelegate: DropDelegate {
    let slotIndex: Int
    weak var viewModel: LevelTestViewModel?

    init(slotIndex: Int, viewModel: LevelTestViewModel) {
        self.slotIndex = slotIndex
        self.viewModel = viewModel
    }

    func performDrop(info: DropInfo) -> Bool {
        guard let itemProvider = info.itemProviders(for: [.text]).first else { return false }

        itemProvider.loadItem(forTypeIdentifier: "public.text", options: nil) { [weak viewModel, slotIndex = self.slotIndex] data, error in
            Task { @MainActor in
                guard let data = data as? Data,
                      let tokenId = String(data: data, encoding: .utf8),
                      let viewModel = viewModel,
                      let token = viewModel.availableTokens.first(where: { $0.id == tokenId }) else {
                    return
                }

                viewModel.placeToken(token, in: slotIndex)
            }
        }

        return true
    }
}

// MARK: - Flow Layout (for wrapping tokens)

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }

            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}

#Preview {
    LevelTestView(onComplete: {})
}
