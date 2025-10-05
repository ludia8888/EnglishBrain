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

    private var hasLoadedInitialData = false
    private var fetchTask: Task<Void, Never>?
    private var openTasks: [UUID: Task<Void, Never>] = [:]

    // MARK: - API Integration

    func fetchDigestIfNeeded() {
        guard !hasLoadedInitialData else { return }
        hasLoadedInitialData = true
        fetchDigest()
    }

    func fetchDigest() {
        // Cancel any existing fetch task
        fetchTask?.cancel()

        fetchTask = Task {
            isLoading = true
            errorMessage = nil

            await withCheckedContinuation { continuation in
                NotificationsAPI.getNotificationDigest { [weak self] response, error in
                    guard let self = self else {
                        continuation.resume()
                        return
                    }

                    Task { @MainActor in
                        guard !Task.isCancelled else {
                            continuation.resume()
                            return
                        }

                        self.isLoading = false

                        if let error = error {
                            self.errorMessage = error.localizedDescription
                            print("❌ Failed to fetch notification digest: \(error)")
                        } else if let digest = response {
                            self.digest = digest
                            print("✅ Fetched \(digest.pending.count) pending notifications")
                        }

                        continuation.resume()
                    }
                }
            }
        }
    }

    func openNotification(_ notification: EnglishBrainAPI.Notification, action: NotificationOpenRequest.ActionTaken) {
        let notificationId = notification.notificationId

        // Cancel any existing task for this notification
        openTasks[notificationId]?.cancel()

        let task = Task {
            let request = NotificationOpenRequest(
                openedAt: Date(),
                surface: .inApp,
                actionTaken: action
            )

            await withCheckedContinuation { continuation in
                NotificationsAPI.openNotification(
                    notificationId: notificationId,
                    notificationOpenRequest: request
                ) { [weak self] response, error in
                    guard let self = self else {
                        continuation.resume()
                        return
                    }

                    Task { @MainActor in
                        guard !Task.isCancelled else {
                            continuation.resume()
                            return
                        }

                        if let error = error {
                            print("❌ Failed to track notification open: \(error)")
                        } else if let response = response {
                            print("✅ Notification open tracked")
                            print("Status: \(response.status)")

                            // Remove from pending list
                            self.digest?.pending.removeAll { $0.notificationId == notificationId }
                        }

                        // Clean up task
                        self.openTasks.removeValue(forKey: notificationId)
                        continuation.resume()
                    }
                }
            }
        }

        openTasks[notificationId] = task
    }

    func dismissNotification(_ notification: EnglishBrainAPI.Notification) {
        openNotification(notification, action: .dismiss)
    }

    deinit {
        fetchTask?.cancel()
        openTasks.values.forEach { $0.cancel() }
    }
}
