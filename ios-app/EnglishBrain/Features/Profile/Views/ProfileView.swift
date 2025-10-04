//
//  ProfileView.swift
//  EnglishBrain
//
//  Created by Claude on 10/4/25.
//

import SwiftUI

struct ProfileView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true

    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.ebPrimary)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("사용자")
                                .font(.ebH4)
                                .foregroundColor(.ebTextPrimary)

                            Text("학습 중")
                                .font(.ebBody)
                                .foregroundColor(.ebTextSecondary)
                        }
                        .padding(.leading, 12)
                    }
                    .padding(.vertical, 8)
                }

                Section("학습 설정") {
                    NavigationLink {
                        Text("목표 설정")
                    } label: {
                        Label("일일 목표", systemImage: "target")
                    }

                    NavigationLink {
                        Text("알림 설정")
                    } label: {
                        Label("알림", systemImage: "bell.fill")
                    }
                }

                Section("앱 정보") {
                    NavigationLink {
                        Text("사용 가이드")
                    } label: {
                        Label("사용 방법", systemImage: "book.fill")
                    }

                    NavigationLink {
                        Text("About")
                    } label: {
                        Label("정보", systemImage: "info.circle")
                    }
                }

                Section {
                    Button(action: {
                        hasCompletedOnboarding = false
                    }) {
                        Label("온보딩 다시 보기", systemImage: "arrow.counterclockwise")
                            .foregroundColor(.ebPrimary)
                    }
                }
            }
            .navigationTitle("프로필")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    ProfileView()
}
