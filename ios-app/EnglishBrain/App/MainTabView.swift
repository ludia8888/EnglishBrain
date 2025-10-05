//
//  MainTabView.swift
//  EnglishBrain
//
//  Created by Claude on 10/4/25.
//

import SwiftUI
import EnglishBrainAPI

struct MainTabView: View {
    @StateObject private var deepLinkRouter = DeepLinkRouter()

    var body: some View {
        TabView(selection: $deepLinkRouter.selectedTab) {
            // Home Tab with NavigationStack
            NavigationStack(path: $deepLinkRouter.homePath) {
                HomeView()
                    .navigationDestination(for: DeepLinkDestination.self) { destination in
                        destinationView(for: destination)
                    }
            }
            .tabItem {
                Label("홈", systemImage: "house.fill")
            }
            .tag(0)

            // Patterns Tab with NavigationStack
            NavigationStack(path: $deepLinkRouter.patternsPath) {
                PatternsListView()
                    .navigationDestination(for: DeepLinkDestination.self) { destination in
                        destinationView(for: destination)
                    }
            }
            .tabItem {
                Label("패턴", systemImage: "chart.line.uptrend.xyaxis")
            }
            .tag(1)

            // Notifications Tab with NavigationStack
            NavigationStack(path: $deepLinkRouter.notificationsPath) {
                NotificationDigestView()
                    .navigationDestination(for: DeepLinkDestination.self) { destination in
                        destinationView(for: destination)
                    }
            }
            .tabItem {
                Label("알림", systemImage: "bell.fill")
            }
            .tag(2)

            // Profile Tab with NavigationStack
            NavigationStack(path: $deepLinkRouter.profilePath) {
                ProfileView()
                    .navigationDestination(for: DeepLinkDestination.self) { destination in
                        destinationView(for: destination)
                    }
            }
            .tabItem {
                Label("프로필", systemImage: "person.fill")
            }
            .tag(3)
        }
        .accentColor(.ebPrimary)
        .environmentObject(deepLinkRouter)
    }

    @ViewBuilder
    private func destinationView(for destination: DeepLinkDestination) -> some View {
        switch destination {
        case .session(let patternId):
            if let patternId = patternId {
                Text("TODO: Session for pattern \(patternId)")
            } else {
                SessionView()
            }

        case .review(let patternId):
            ReviewView(patternId: patternId, targetSentences: 6)

        case .brainBurst:
            Text("TODO: Brain Burst explanation")
                .navigationTitle("Brain Burst")

        case .pattern(let id):
            // TODO: Create PatternDetailView that takes pattern ID
            Text("TODO: Pattern detail for \(id)")
                .navigationTitle("패턴 상세")

        case .unknown:
            Text("잘못된 링크예요")
                .navigationTitle("오류")
        }
    }
}

#Preview {
    MainTabView()
}