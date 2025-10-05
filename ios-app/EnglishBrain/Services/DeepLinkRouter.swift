//
//  DeepLinkRouter.swift
//  EnglishBrain
//
//  Created by Claude on 10/4/25.
//

import Foundation
import SwiftUI

// MARK: - DeepLink Security Validator

enum DeepLinkValidationError: Error {
    case invalidScheme
    case invalidHost
    case pathTraversalAttempt
    case invalidUUID
    case maliciousInput
    case unknownRoute

    var userFriendlyMessage: String {
        switch self {
        case .invalidScheme, .invalidHost, .unknownRoute:
            return "잘못된 링크입니다"
        case .pathTraversalAttempt, .maliciousInput:
            return "유효하지 않은 요청입니다"
        case .invalidUUID:
            return "잘못된 링크 형식입니다"
        }
    }
}

struct DeepLinkValidator {
    private static let allowedSchemes = ["englishbrain", "https"]
    private static let allowedHosts = ["app.englishbrain.com", "englishbrain.app", "englishbrain"]

    /// Validates and sanitizes a deeplink URL
    static func validate(_ deeplink: String) -> Result<URL, DeepLinkValidationError> {
        // Basic URL validation
        guard let url = URL(string: deeplink) else {
            return .failure(.invalidScheme)
        }

        // Scheme validation
        guard let scheme = url.scheme?.lowercased(),
              allowedSchemes.contains(scheme) else {
            return .failure(.invalidScheme)
        }

        // Host validation (nil host allowed for custom scheme)
        if let host = url.host?.lowercased() {
            guard allowedHosts.contains(host) else {
                return .failure(.invalidHost)
            }
        }

        // Path traversal detection
        let path = url.path
        if path.contains("..") || path.contains("//") {
            return .failure(.pathTraversalAttempt)
        }

        // Malicious character detection
        let maliciousChars = ["<", ">", "\"", "'", ";", "`"]
        if maliciousChars.contains(where: { deeplink.contains($0) }) {
            return .failure(.maliciousInput)
        }

        return .success(url)
    }

    /// Validates UUID string
    static func validateUUID(_ uuidString: String) -> Result<UUID, DeepLinkValidationError> {
        guard let uuid = UUID(uuidString: uuidString) else {
            return .failure(.invalidUUID)
        }
        return .success(uuid)
    }

    /// Sanitizes string parameter (removes special characters)
    static func sanitize(_ input: String) -> String {
        let allowedCharacterSet = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_"))
        return input.components(separatedBy: allowedCharacterSet.inverted).joined()
    }
}

// MARK: - DeepLink Destination

enum DeepLinkDestination: Hashable, Equatable {
    case session(patternId: String?)
    case review(patternId: String?)
    case brainBurst
    case pattern(id: String)
    case unknown
}

@MainActor
class DeepLinkRouter: ObservableObject {
    // Navigation paths for each tab (iOS 16+ NavigationStack)
    @Published var homePath: [DeepLinkDestination] = []
    @Published var patternsPath: [DeepLinkDestination] = []
    @Published var notificationsPath: [DeepLinkDestination] = []
    @Published var profilePath: [DeepLinkDestination] = []

    // Active tab selection
    @Published var selectedTab: Int = 0

    // Validation error
    @Published var validationError: String?

    /// Parse deep link URL and navigate to appropriate destination
    func handle(deeplink: String) {
        // Validate deep link security
        let validationResult = DeepLinkValidator.validate(deeplink)

        switch validationResult {
        case .success(let url):
            parseAndNavigate(url: url)
        case .failure(let error):
            print("❌ Deep link validation failed: \(error)")
            validationError = error.userFriendlyMessage
        }
    }

    private func parseAndNavigate(url: URL) {
        let path = url.path
        let components = path.split(separator: "/").map(String.init)
        let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems

        print("🔗 Handling deep link: \(url.absoluteString)")
        print("Path: \(path), Components: \(components)")

        // Clear any previous validation errors
        validationError = nil

        switch components.first {
        case "home":
            selectedTab = 0
            homePath.removeAll()

        case "session":
            let patternId = sanitizePatternId(queryItems?.first(where: { $0.name == "pattern" })?.value)
            selectedTab = 0
            homePath.append(.session(patternId: patternId))

        case "review":
            let patternId = sanitizePatternId(queryItems?.first(where: { $0.name == "pattern" })?.value)
            selectedTab = 0
            homePath.append(.review(patternId: patternId))

        case "brain-burst":
            selectedTab = 0
            homePath.append(.brainBurst)

        case "pattern":
            selectedTab = 1
            if components.count > 1 {
                let sanitizedId = DeepLinkValidator.sanitize(components[1])
                guard !sanitizedId.isEmpty else {
                    print("⚠️ Invalid pattern ID after sanitization")
                    return
                }
                patternsPath.append(.pattern(id: sanitizedId))
            }

        case "profile":
            selectedTab = 3
            profilePath.removeAll()

        case "streak":
            selectedTab = 3
            profilePath.removeAll()
            // TODO: Add scroll to streak section

        default:
            print("⚠️ Unhandled deep link path: \(path)")
            selectedTab = 0
        }
    }

    private func sanitizePatternId(_ patternId: String?) -> String? {
        guard let patternId = patternId else { return nil }

        // Try UUID validation first
        if case .success(let uuid) = DeepLinkValidator.validateUUID(patternId) {
            return uuid.uuidString
        }

        // Fall back to string sanitization
        let sanitized = DeepLinkValidator.sanitize(patternId)
        return sanitized.isEmpty ? nil : sanitized
    }

    func popToRoot(tab: Int) {
        switch tab {
        case 0:
            homePath.removeAll()
        case 1:
            patternsPath.removeAll()
        case 2:
            notificationsPath.removeAll()
        case 3:
            profilePath.removeAll()
        default:
            break
        }
    }
}
