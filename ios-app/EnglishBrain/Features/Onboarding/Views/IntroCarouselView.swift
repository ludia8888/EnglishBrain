//
//  IntroCarouselView.swift
//  EnglishBrain
//
//  Created by Claude on 10/4/25.
//

import SwiftUI

struct IntroCarouselView: View {
    @State private var currentPage = 0
    let onComplete: () -> Void

    let pages: [IntroPage] = [
        IntroPage(
            icon: "brain.head.profile",
            title: "영어로 생각하기",
            description: "번역이 아니라, 영어로 직접 생각하는\n회로를 만들어드릴게요"
        ),
        IntroPage(
            icon: "arrow.triangle.swap",
            title: "블록으로 문장 만들기",
            description: "손끝으로 영어 어순을 체화하세요\n드래그할수록 자연스러워져요"
        ),
        IntroPage(
            icon: "chart.line.uptrend.xyaxis",
            title: "약점을 정복해요",
            description: "당신만의 약점을 찾아\n집중 훈련으로 바꿔드릴게요"
        ),
        IntroPage(
            icon: "flame.fill",
            title: "매일 10분, 습관으로",
            description: "하루 12문장이면 충분해요\n연속 학습 기록이 곧 당신의 성장이에요"
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Skip button
            HStack {
                Spacer()
                Button("건너뛰기") {
                    onComplete()
                }
                .font(.ebLabel)
                .foregroundColor(.ebTextSecondary)
                .padding()
            }

            Spacer()

            // Carousel
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    IntroPageView(page: pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 450)

            // Page indicator
            HStack(spacing: 8) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Circle()
                        .fill(currentPage == index ? Color.ebPrimary : Color.ebDivider)
                        .frame(width: 8, height: 8)
                        .animation(.easeInOut, value: currentPage)
                }
            }
            .padding(.bottom, 32)

            Spacer()

            // Bottom button
            if currentPage == pages.count - 1 {
                PrimaryButton(title: "시작하기", action: onComplete)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                    .transition(.opacity)
            } else {
                PrimaryButton(
                    title: "다음",
                    action: {
                        withAnimation {
                            currentPage += 1
                        }
                    },
                    style: .outline
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
                .transition(.opacity)
            }
        }
        .background(Color.ebBackground)
    }
}

struct IntroPage {
    let icon: String
    let title: String
    let description: String
}

struct IntroPageView: View {
    let page: IntroPage

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: page.icon)
                .font(.system(size: 80))
                .foregroundColor(.ebPrimary)
                .padding(.bottom, 16)

            Text(page.title)
                .font(.ebH2)
                .foregroundColor(.ebTextPrimary)

            Text(page.description)
                .font(.ebBodyLarge)
                .foregroundColor(.ebTextSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .padding(.horizontal, 32)
    }
}

#Preview {
    IntroCarouselView(onComplete: {})
}
