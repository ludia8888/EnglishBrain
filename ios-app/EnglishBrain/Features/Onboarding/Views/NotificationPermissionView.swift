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
                Text("알림으로 습관 만들기")
                    .font(.ebH2)
                    .foregroundColor(.ebTextPrimary)

                Text("매일 최적의 시간에 알림을 보내드려요.\n스트릭을 유지하고 Brain Token을 얻을 수 있어요!")
                    .font(.ebBodyLarge)
                    .foregroundColor(.ebTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal, 32)

            Spacer()

            // Benefits
            VStack(spacing: 16) {
                BenefitRow(icon: "clock.fill", text: "개인화된 시간대 (DND 제외)")
                BenefitRow(icon: "chart.line.uptrend.xyaxis", text: "약점 패턴 중심 리마인더")
                BenefitRow(icon: "flame.fill", text: "스트릭 보호 Brain Token 알림")
            }
            .padding(.horizontal, 32)

            Spacer()

            // Buttons
            VStack(spacing: 12) {
                PrimaryButton(title: "알림 받기", action: onAllow)

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
