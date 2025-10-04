//
//  ReviewView.swift
//  EnglishBrain
//
//  Created by Claude on 10/4/25.
//

import SwiftUI
import EnglishBrainAPI

struct ReviewView: View {
    @StateObject private var viewModel = ReviewViewModel()
    @Environment(\.dismiss) private var dismiss

    let patternId: String?
    let targetSentences: Int

    init(patternId: String? = nil, targetSentences: Int = 6) {
        self.patternId = patternId
        self.targetSentences = targetSentences
    }

    var body: some View {
        ZStack {
            Color.ebBackground.ignoresSafeArea()

            if viewModel.isLoading {
                loadingView
            } else if let error = viewModel.errorMessage {
                errorView(error)
            } else if viewModel.isCompleted {
                completionView
            } else if viewModel.reviewPlan != nil {
                reviewContentView
            } else {
                loadingView
            }
        }
        .onAppear {
            viewModel.createReview(patternId: patternId, targetSentences: targetSentences)
        }
    }

    // MARK: - Review Content

    private var reviewContentView: some View {
        VStack(spacing: 0) {
            headerView
            progressBarView

            ScrollView {
                VStack(spacing: 24) {
                    if let item = viewModel.currentItem {
                        promptView(item)
                        slotsView
                        tokensView
                        submitButton
                    }
                }
                .padding()
            }
        }
    }

    private var headerView: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.ebBody)
                    .foregroundColor(.ebTextSecondary)
            }

            Spacer()

            VStack(spacing: 2) {
                Text("패턴 복습")
                    .font(.ebLabel)
                    .foregroundColor(.ebTextSecondary)

                if let plan = viewModel.reviewPlan {
                    Text("\(viewModel.currentItemIndex + 1) / \(plan.items.count)")
                        .font(.ebH3)
                        .foregroundColor(.ebTextPrimary)
                }
            }

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.ebSuccess)
                Text("\(viewModel.correctCount)")
                    .font(.ebBody)
                    .foregroundColor(.ebTextPrimary)
            }
        }
        .padding()
        .background(Color.ebCard)
    }

    private var progressBarView: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.ebPrimaryLight.opacity(0.2))

                Rectangle()
                    .fill(Color.ebPrimary)
                    .frame(width: geometry.size.width * viewModel.progress)
            }
        }
        .frame(height: 4)
    }

    private func promptView(_ item: ReviewItem) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "text.bubble")
                    .foregroundColor(.ebPrimary)
                Text("복습 문제")
                    .font(.ebLabel)
                    .foregroundColor(.ebTextSecondary)
            }

            Text(item.prompt.ko)
                .font(.ebH3)
                .foregroundColor(.ebTextPrimary)

            if !item.patternTags.isEmpty {
                HStack(spacing: 8) {
                    ForEach(item.patternTags, id: \.self) { tag in
                        Text(tag)
                            .font(.ebCaption)
                            .foregroundColor(.ebPrimary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.ebPrimaryLight.opacity(0.2))
                            .cornerRadius(12)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.ebCard)
        .cornerRadius(16)
    }

    private var slotsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("문장 구성하기")
                .font(.ebLabel)
                .foregroundColor(.ebTextSecondary)

            HStack(spacing: 12) {
                ForEach(Array(viewModel.slots.enumerated()), id: \.offset) { index, slot in
                    slotButton(slot: slot, index: index)
                }
            }
        }
    }

    private func slotButton(slot: ReviewViewModel.SlotItem, index: Int) -> some View {
        Button(action: {
            if slot.token != nil {
                viewModel.removeTokenFromSlot(index: index)
            } else {
                viewModel.tapSlot(index: index)
            }
        }) {
            VStack(spacing: 4) {
                Text(slot.slotType)
                    .font(.ebCaption)
                    .foregroundColor(slotColor(slot.slotType))

                if let token = slot.token {
                    Text(token.text)
                        .font(.ebBody)
                        .foregroundColor(.ebTextPrimary)
                } else {
                    Text("___")
                        .font(.ebBody)
                        .foregroundColor(.ebTextTertiary)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(
                slot.token != nil ?
                    slotColor(slot.slotType).opacity(0.2) :
                    Color.ebCard
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(slotColor(slot.slotType), lineWidth: 2)
            )
        }
    }

    private func slotColor(_ type: String) -> Color {
        switch type {
        case "S": return .ebSlotSubject
        case "V": return .ebSlotVerb
        case "O": return .ebSlotObject
        case "M": return .ebSlotModifier
        default: return .ebPrimary
        }
    }

    private var tokensView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("사용 가능한 단어")
                .font(.ebLabel)
                .foregroundColor(.ebTextSecondary)

            FlowLayout(spacing: 12) {
                ForEach(viewModel.availableTokens) { token in
                    tokenButton(token: token)
                }
            }
        }
    }

    private func tokenButton(token: ReviewViewModel.TokenDragItem) -> some View {
        Button(action: {
            viewModel.selectToken(token.id)
        }) {
            Text(token.text)
                .font(.ebBody)
                .foregroundColor(.ebTextPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    viewModel.selectedTokenId == token.id ?
                        Color.ebPrimary.opacity(0.3) :
                        Color.ebPrimaryLight.opacity(0.2)
                )
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            viewModel.selectedTokenId == token.id ?
                                Color.ebPrimary :
                                Color.clear,
                            lineWidth: 2
                        )
                )
        }
    }

    private var submitButton: some View {
        PrimaryButton(
            title: "확인",
            action: { viewModel.submitAnswer() },
            isEnabled: viewModel.slots.allSatisfy { $0.token != nil }
        )
        .padding(.top, 8)
    }

    // MARK: - Loading & Error States

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("복습 준비 중...")
                .font(.ebBody)
                .foregroundColor(.ebTextSecondary)
        }
    }

    private func errorView(_ error: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.ebError)

            Text("복습을 불러올 수 없습니다")
                .font(.ebH3)
                .foregroundColor(.ebTextPrimary)

            Text(error)
                .font(.ebBody)
                .foregroundColor(.ebTextSecondary)
                .multilineTextAlignment(.center)

            PrimaryButton(
                title: "닫기",
                action: { dismiss() }
            )
            .padding(.horizontal, 32)
        }
        .padding()
    }

    // MARK: - Completion View

    private var completionView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(.ebSuccess)

            Text("복습 완료!")
                .font(.ebH2)
                .foregroundColor(.ebTextPrimary)

            statsCard

            Spacer()

            PrimaryButton(
                title: "홈으로",
                action: { dismiss() }
            )
            .padding(.horizontal, 32)
        }
        .padding()
    }

    private var statsCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text("정답률")
                    .font(.ebBody)
                    .foregroundColor(.ebTextSecondary)
                Spacer()
                if viewModel.totalAttempts > 0 {
                    Text("\(Int(Double(viewModel.correctCount) / Double(viewModel.totalAttempts) * 100))%")
                        .font(.ebH3)
                        .foregroundColor(.ebSuccess)
                }
            }

            HStack {
                Text("맞힌 문제")
                    .font(.ebBody)
                    .foregroundColor(.ebTextSecondary)
                Spacer()
                Text("\(viewModel.correctCount) / \(viewModel.totalAttempts)")
                    .font(.ebH3)
                    .foregroundColor(.ebTextPrimary)
            }
        }
        .padding()
        .background(Color.ebCard)
        .cornerRadius(16)
    }
}
