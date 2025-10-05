//
//  TutorialView.swift
//  EnglishBrain
//
//  Created by Claude on 10/4/25.
//

import SwiftUI
import AVFoundation
import UIKit

struct TutorialView: View {
    @State private var currentStep = 0
    @State private var audioPlayer: AVAudioPlayer?
    @State private var hasPlayedAudio = false
    @State private var hasTriggeredHaptic = false
    @State private var hasSeenVisual = false
    let onComplete: () -> Void

    let tutorialSentence = TutorialSentence(
        korean: "나는 사과를 좋아한다",
        tokens: [
            TutorialToken(id: "t1", text: "I", correctSlot: .subject),
            TutorialToken(id: "t2", text: "like", correctSlot: .verb),
            TutorialToken(id: "t3", text: "apples", correctSlot: .object)
        ]
    )

    var body: some View {
        VStack(spacing: 32) {
            // Header
            Text("세 가지 방식으로 느껴보세요")
                .font(.ebH3)
                .foregroundColor(.ebTextPrimary)
                .padding(.top, 32)

            // Korean sentence
            Text(tutorialSentence.korean)
                .font(.ebH4)
                .foregroundColor(.ebTextSecondary)

            Spacer()

            // Feedback channels demonstration
            VStack(spacing: 24) {
                // 1. Visual Feedback
                FeedbackChannelCard(
                    icon: "eye.fill",
                    title: "눈으로",
                    color: .ebFeedbackVisual,
                    isActive: hasSeenVisual,
                    description: "정답이면 초록 불꽃이,\n오답이면 흔들림이 보여요"
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        hasSeenVisual = true
                    }
                }

                // 2. Audio Feedback
                FeedbackChannelCard(
                    icon: "speaker.wave.2.fill",
                    title: "귀로",
                    color: .ebFeedbackAudio,
                    isActive: hasPlayedAudio,
                    description: "정답 벨소리, 콤보 효과음\n소리로도 성취감을 느껴보세요"
                ) {
                    playSuccessSound()
                    hasPlayedAudio = true
                }

                // 3. Haptic Feedback
                FeedbackChannelCard(
                    icon: "hand.tap.fill",
                    title: "손끝으로",
                    color: .ebFeedbackHaptic,
                    isActive: hasTriggeredHaptic,
                    description: "진동으로 손끝에 전해지는\n정답의 짜릿함"
                ) {
                    triggerHapticFeedback()
                    hasTriggeredHaptic = true
                }
            }
            .padding(.horizontal)

            Spacer()

            // Complete button
            if hasSeenVisual && hasPlayedAudio && hasTriggeredHaptic {
                VStack(spacing: 16) {
                    Text("완벽해요! 이제 시작할 준비가 됐어요")
                        .font(.ebLabel)
                        .foregroundColor(.ebSuccess)

                    PrimaryButton(title: "시작하기", action: onComplete)
                        .padding(.horizontal, 24)
                }
                .transition(.opacity)
            } else {
                Text("카드를 탭해서 각 피드백을 체험해보세요")
                    .font(.ebBodySmall)
                    .foregroundColor(.ebTextSecondary)
                    .padding(.horizontal, 24)
            }

            Spacer()
        }
        .background(Color.ebBackground)
    }

    private func playSuccessSound() {
        // Generate success beep (실제로는 assets에서 로드)
        guard let url = Bundle.main.url(forResource: "success", withExtension: "mp3") else {
            // Fallback: system sound
            AudioServicesPlaySystemSound(1057) // Modern payment success sound
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            AudioServicesPlaySystemSound(1057)
        }
    }

    private func triggerHapticFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        // Add additional impact for emphasis
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 100_000_000)
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
        }
    }
}

struct TutorialSentence {
    let korean: String
    let tokens: [TutorialToken]
}

struct TutorialToken: Identifiable {
    let id: String
    let text: String
    let correctSlot: SlotType
}

struct FeedbackChannelCard: View {
    let icon: String
    let title: String
    let color: Color
    let isActive: Bool
    let description: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 60, height: 60)

                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(color)
                }
                .scaleEffect(isActive ? 1.1 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isActive)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(title)
                            .font(.ebH5)
                            .foregroundColor(.ebTextPrimary)

                        if isActive {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.ebSuccess)
                                .transition(.scale)
                        }
                    }

                    Text(description)
                        .font(.ebBodySmall)
                        .foregroundColor(.ebTextSecondary)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(2)
                }

                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.ebSurface)
                    .shadow(color: isActive ? color.opacity(0.3) : .black.opacity(0.05), radius: isActive ? 8 : 4, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(isActive ? color : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    TutorialView(onComplete: {})
}
