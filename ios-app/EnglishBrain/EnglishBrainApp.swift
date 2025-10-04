//
//  EnglishBrainApp.swift
//  EnglishBrain
//
//  Created by 이시현 on 10/4/25.
//

import SwiftUI

@main
struct EnglishBrainApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    init() {
        // Configure API
        APIConfiguration.shared.configure()
    }

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                ContentView()
            } else {
                OnboardingCoordinator {
                    hasCompletedOnboarding = true
                }
            }
        }
    }
}
