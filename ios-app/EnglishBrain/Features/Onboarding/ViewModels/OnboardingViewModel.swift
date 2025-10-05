//
//  OnboardingViewModel.swift
//  EnglishBrain
//
//  Created by Claude on 10/4/25.
//

import Foundation
import UserNotifications
import EnglishBrainAPI

@MainActor
class OnboardingViewModel: ObservableObject {
    @Published var currentStep: OnboardingStep = .intro
    @Published var isLoading = false
    @Published var errorMessage: String?

    enum OnboardingStep {
        case intro
        case levelTest
        case tutorial
        case notificationPermission
        case complete
    }

    func moveToNextStep() {
        switch currentStep {
        case .intro:
            currentStep = .levelTest
        case .levelTest:
            currentStep = .tutorial
        case .tutorial:
            // Delayed notification permission (value-first approach)
            currentStep = .notificationPermission
        case .notificationPermission:
            completeOnboarding()
        case .complete:
            break
        }
    }

    func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            Task { @MainActor in
                if let error = error {
                    print("Notification permission error: \(error)")
                }
                completion(granted)
            }
        }
    }

    func skipNotificationPermission() {
        completeOnboarding()
    }

    private func completeOnboarding() {
        isLoading = true
        errorMessage = nil

        // Mark tutorial as completed via API
        let request = TutorialCompletionRequest(
            tutorialId: "onboarding_complete",
            completedAt: Date(),
            liveActivityId: nil
        )

        OnboardingAPI.createTutorialCompletion(tutorialCompletionRequest: request) { [weak self] response, error in
            Task { @MainActor [weak self] in
                self?.isLoading = false

                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    print("❌ Tutorial completion failed: \(error)")
                    // Still proceed to complete step for better UX, retry can happen in background
                    self?.currentStep = .complete
                } else if let response = response {
                    print("✅ Tutorial marked as complete")
                    print("Tutorial ID: \(response.tutorialId)")
                    print("Streak eligible: \(response.streakEligible)")
                    print("Personalization unlocked: \(response.personalizationUnlocked)")
                    self?.currentStep = .complete
                }
            }
        }
    }
}
