//
//  MainTabView.swift
//  EnglishBrain
//
//  Created by Claude on 10/4/25.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

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

            ProfileView()
                .tabItem {
                    Label("프로필", systemImage: "person.fill")
                }
                .tag(2)
        }
        .accentColor(.ebPrimary)
    }
}

#Preview {
    MainTabView()
}
