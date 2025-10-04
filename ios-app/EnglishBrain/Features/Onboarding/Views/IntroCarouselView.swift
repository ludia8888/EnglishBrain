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
            title: "Think like English",
            description: "영어를 단순히 번역하지 않고\n영어식 사고로 문장을 만들어요"
        ),
        IntroPage(
            icon: "arrow.triangle.swap",
            title: "Drag & Build Sentences",
            description: "단어 블록을 드래그하며\nS-V-O-M 어순으로 문장을 완성해요"
        ),
        IntroPage(
            icon: "chart.line.uptrend.xyaxis",
            title: "Pattern Mastery",
            description: "AI가 분석한 약점 패턴을\n집중 훈련으로 정복해요"
        ),
        IntroPage(
            icon: "flame.fill",
            title: "Build Your Streak",
            description: "매일 12문장으로 습관을 만들고\nBrain Token으로 스트릭을 지켜요"
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Skip button
            HStack {
                Spacer()
                Button("Skip") {
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
