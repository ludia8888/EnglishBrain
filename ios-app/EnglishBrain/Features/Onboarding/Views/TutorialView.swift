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
            Text("3가지 피드백 채널 체험")
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
                    title: "시각 피드백",
                    color: .ebFeedbackVisual,
                    isActive: hasSeenVisual,
                    description: "슬롯 색상과 애니메이션으로\n정답/오답을 즉시 확인"
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        hasSeenVisual = true
                    }
                }

                // 2. Audio Feedback
                FeedbackChannelCard(
                    icon: "speaker.wave.2.fill",
                    title: "청각 피드백",
                    color: .ebFeedbackAudio,
                    isActive: hasPlayedAudio,
                    description: "효과음으로 정답/오답과\n콤보 달성을 귀로 느끼기"
                ) {
                    playSuccessSound()
                    hasPlayedAudio = true
                }

                // 3. Haptic Feedback
                FeedbackChannelCard(
                    icon: "hand.tap.fill",
                    title: "촉각 피드백",
                    color: .ebFeedbackHaptic,
                    isActive: hasTriggeredHaptic,
                    description: "정교한 진동으로\n손끝에서 느끼는 성취감"
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
                    Text("✅ 모든 피드백 채널을 체험했습니다!")
                        .font(.ebLabel)
                        .foregroundColor(.ebSuccess)

                    PrimaryButton(title: "튜토리얼 완료", action: onComplete)
                        .padding(.horizontal, 24)
                }
                .transition(.opacity)
            } else {
                Text("각 카드를 탭하여 피드백을 체험해보세요")
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
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
