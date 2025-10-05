//
//  NotificationDigestView.swift
//  EnglishBrain
//
//  Created by Claude on 10/4/25.
//

import SwiftUI
import EnglishBrainAPI

struct NotificationDigestView: View {
    @StateObject private var viewModel = NotificationViewModel()
    @EnvironmentObject private var deepLinkRouter: DeepLinkRouter

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if let digest = viewModel.digest, !digest.pending.isEmpty {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(digest.pending, id: \.notificationId) { notification in
                            NotificationCard(
                                notification: notification,
                                onTap: {
                                    handleNotificationTap(notification)
                                },
                                onDismiss: {
                                    viewModel.dismissNotification(notification)
                                }
                            )
                        }
                    }
                    .padding()
                }
            } else {
                emptyState
            }
        }
        .navigationTitle("알림")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.fetchDigest()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .task {
            viewModel.fetchDigestIfNeeded()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "bell.slash")
                .font(.system(size: 48))
                .foregroundColor(.ebTextSecondary)

            Text("알림 없음")
                .font(.ebH3)
                .foregroundColor(.ebTextPrimary)

            Text("모두 확인하셨어요!")
                .font(.ebBody)
                .foregroundColor(.ebTextSecondary)
        }
    }

    private func handleNotificationTap(_ notification: EnglishBrainAPI.Notification) {
        // Determine action based on category
        let action: NotificationOpenRequest.ActionTaken = switch notification.category {
        case .streak:
            .session
        case .pattern:
            .review
        case .reminder:
            .session
        case .promo:
            .unknown
        }

        // Track the open
        viewModel.openNotification(notification, action: action)

        // Navigate via deep link
        deepLinkRouter.handle(deeplink: notification.deeplink)
    }
}

struct NotificationCard: View {
    let notification: EnglishBrainAPI.Notification
    let onTap: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 12) {
                categoryIcon
                    .frame(width: 40, height: 40)
                    .background(categoryColor.opacity(0.1))
                    .cornerRadius(20)

                VStack(alignment: .leading, spacing: 4) {
                    Text(notification.title)
                        .font(.ebLabel)
                        .foregroundColor(.ebTextPrimary)

                    Text(notification.body)
                        .font(.ebCaption)
                        .foregroundColor(.ebTextSecondary)
                        .lineLimit(2)

                    Text(timeAgo)
                        .font(.system(size: 11))
                        .foregroundColor(.ebTextTertiary)
                }

                Spacer()

                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.ebTextTertiary)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(Color.ebCard)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }

    private var categoryIcon: some View {
        Group {
            switch notification.category {
            case .streak:
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
            case .pattern:
                Image(systemName: "brain.head.profile")
                    .foregroundColor(.ebPrimary)
            case .reminder:
                Image(systemName: "bell.fill")
                    .foregroundColor(.blue)
            case .promo:
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
            }
        }
        .font(.system(size: 20))
    }

    private var categoryColor: Color {
        switch notification.category {
        case .streak:
            return .orange
        case .pattern:
            return .ebPrimary
        case .reminder:
            return .blue
        case .promo:
            return .yellow
        }
    }

    private var timeAgo: String {
        let interval = Date().timeIntervalSince(notification.deliveryAt)
        let minutes = Int(interval / 60)
        let hours = Int(interval / 3600)
        let days = Int(interval / 86400)

        if days > 0 {
            return "\(days)일 전"
        } else if hours > 0 {
            return "\(hours)시간 전"
        } else if minutes > 0 {
            return "\(minutes)분 전"
        } else {
            return "방금"
        }
    }
}

#Preview {
    NotificationDigestView()
        .environmentObject(DeepLinkRouter())
}
