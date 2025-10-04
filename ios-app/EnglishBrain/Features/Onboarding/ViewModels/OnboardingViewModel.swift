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
            DispatchQueue.main.async {
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

        // Mark tutorial as completed via API
        // UsersAPI.markTutorialComplete { [weak self] response, error in
        //     DispatchQueue.main.async {
        //         self?.isLoading = false
        //         if error == nil {
        //             self?.currentStep = .complete
        //         }
        //     }
        // }

        // Mock completion
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isLoading = false
            self?.currentStep = .complete
        }
    }
}
