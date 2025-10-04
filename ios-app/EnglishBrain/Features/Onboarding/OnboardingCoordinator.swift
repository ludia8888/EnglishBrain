//
//  OnboardingCoordinator.swift
//  EnglishBrain
//
//  Created by Claude on 10/4/25.
//

import SwiftUI

struct OnboardingCoordinator: View {
    @StateObject private var viewModel = OnboardingViewModel()
    let onComplete: () -> Void

    var body: some View {
        Group {
            switch viewModel.currentStep {
            case .intro:
                IntroCarouselView {
                    viewModel.moveToNextStep()
                }

            case .levelTest:
                LevelTestView {
                    viewModel.moveToNextStep()
                }

            case .tutorial:
                TutorialView {
                    viewModel.moveToNextStep()
                }

            case .notificationPermission:
                NotificationPermissionView(
                    onAllow: {
                        viewModel.requestNotificationPermission { granted in
                            viewModel.moveToNextStep()
                        }
                    },
                    onSkip: {
                        viewModel.skipNotificationPermission()
                    }
                )

            case .complete:
                Color.clear
                    .onAppear {
                        onComplete()
                    }
            }
        }
        .transition(.opacity)
        .animation(.easeInOut, value: viewModel.currentStep)
    }
}

#Preview {
    OnboardingCoordinator(onComplete: {})
}
