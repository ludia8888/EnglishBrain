//
//  NotificationViewModel.swift
//  EnglishBrain
//
//  Created by Claude on 10/4/25.
//

import Foundation
import Combine
import EnglishBrainAPI

@MainActor
class NotificationViewModel: ObservableObject {
    @Published var digest: NotificationDigest?
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - API Integration

    func fetchDigest() {
        isLoading = true
        errorMessage = nil

        NotificationsAPI.getNotificationDigest { [weak self] response, error in
            DispatchQueue.main.async {
                self?.isLoading = false

                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    print("❌ Failed to fetch notification digest: \(error)")
                } else if let digest = response {
                    self?.digest = digest
                    print("✅ Fetched \(digest.pending.count) pending notifications")
                }
            }
        }
    }

    func openNotification(_ notification: EnglishBrainAPI.Notification, action: NotificationOpenRequest.ActionTaken) {
        let request = NotificationOpenRequest(
            openedAt: Date(),
            surface: .inApp,
            actionTaken: action
        )

        NotificationsAPI.openNotification(
            notificationId: notification.notificationId,
            notificationOpenRequest: request
        ) { [weak self] response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Failed to track notification open: \(error)")
                } else if let response = response {
                    print("✅ Notification open tracked")
                    print("Status: \(response.status)")

                    // Remove from pending list
                    self?.digest?.pending.removeAll { $0.notificationId == notification.notificationId }
                }
            }
        }
    }

    func dismissNotification(_ notification: EnglishBrainAPI.Notification) {
        openNotification(notification, action: .dismiss)
    }
}
