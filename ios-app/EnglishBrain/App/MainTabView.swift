//
//  MainTabView.swift
//  EnglishBrain
//
//  Created by Claude on 10/4/25.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var deepLinkRouter = DeepLinkRouter()
    @State private var selectedTab = 0
    @State private var showSessionView = false
    @State private var showReviewView = false
    @State private var sessionPatternId: String?
    @State private var reviewPatternId: String?

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("홈", systemImage: "house.fill")
                }
                .tag(0)

            PatternsListView()
                .tabItem {
                    Label("패턴", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(1)

            NotificationDigestView()
                .tabItem {
                    Label("알림", systemImage: "bell.fill")
                }
                .tag(2)

            ProfileView()
                .tabItem {
                    Label("프로필", systemImage: "person.fill")
                }
                .tag(3)
        }
        .accentColor(.ebPrimary)
        .environmentObject(deepLinkRouter)
        .sheet(isPresented: $showSessionView) {
            if let patternId = sessionPatternId {
                Text("TODO: Start session for pattern \(patternId)")
            } else {
                Text("TODO: Start daily session")
            }
        }
        .sheet(isPresented: $showReviewView) {
            if let patternId = reviewPatternId {
                Text("TODO: Start review for pattern \(patternId)")
            } else {
                Text("TODO: Start general review")
            }
        }
        .onChange(of: deepLinkRouter.activeDestination) { destination in
            handleDeepLink(destination)
        }
    }

    private func handleDeepLink(_ destination: DeepLinkDestination?) {
        guard let destination = destination else { return }

        switch destination {
        case .home:
            selectedTab = 0

        case .session(let patternId):
            sessionPatternId = patternId
            showSessionView = true

        case .review(let patternId):
            reviewPatternId = patternId
            showReviewView = true

        case .brainBurst:
            // TODO: Show Brain Burst explanation or start session
            selectedTab = 0

        case .pattern(let id):
            // TODO: Navigate to pattern detail
            selectedTab = 1
            print("TODO: Navigate to pattern \(id)")

        case .profile:
            selectedTab = 3

        case .streak:
            selectedTab = 3
            // TODO: Scroll to streak section

        case .unknown:
            print("⚠️ Unknown destination")
        }

        // Reset after handling
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            deepLinkRouter.reset()
        }
    }
}

#Preview {
    MainTabView()
}
