//
//  NotificationPermissionView.swift
//  EnglishBrain
//
//  Created by Claude on 10/4/25.
//

import SwiftUI

struct NotificationPermissionView: View {
    let onAllow: () -> Void
    let onSkip: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(Color.ebPrimary.opacity(0.1))
                    .frame(width: 120, height: 120)

                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.ebPrimary)
            }

            // Title & Description
            VStack(spacing: 16) {
                Text("매일 만날까요?")
                    .font(.ebH2)
                    .foregroundColor(.ebTextPrimary)

                Text("당신이 가장 집중하는 시간에 찾아갈게요\n연속 학습과 성장 소식을 전해드릴게요")
                    .font(.ebBodyLarge)
                    .foregroundColor(.ebTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal, 32)

            Spacer()

            // Benefits
            VStack(spacing: 16) {
                BenefitRow(icon: "clock.fill", text: "방해금지 시간은 피해요")
                BenefitRow(icon: "chart.line.uptrend.xyaxis", text: "어제 어려웠던 패턴 복습 알림")
                BenefitRow(icon: "flame.fill", text: "연속 기록 위기 때 구조 신호")
            }
            .padding(.horizontal, 32)

            Spacer()

            // Buttons
            VStack(spacing: 12) {
                PrimaryButton(title: "알림 켜기", action: onAllow)

                Button("나중에") {
                    onSkip()
                }
                .font(.ebLabel)
                .foregroundColor(.ebTextSecondary)
                .padding()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .background(Color.ebBackground)
    }
}

struct BenefitRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.ebPrimary)
                .frame(width: 30)

            Text(text)
                .font(.ebBody)
                .foregroundColor(.ebTextPrimary)

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.ebSurface)
        )
    }
}

#Preview {
    NotificationPermissionView(onAllow: {}, onSkip: {})
}
