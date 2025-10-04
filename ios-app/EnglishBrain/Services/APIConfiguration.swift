//
//  APIConfiguration.swift
//  EnglishBrain
//
//  Created by Claude on 10/4/25.
//

import Foundation
import EnglishBrainAPI

enum APIEnvironment {
    case development
    case staging
    case production

    var baseURL: String {
        switch self {
        case .development:
            return "http://127.0.0.1:3001"  // Prism mock server
        case .staging:
            return "https://staging-api.englishbrain.app"
        case .production:
            return "https://api.englishbrain.app"
        }
    }

    var requiresAuth: Bool {
        switch self {
        case .development:
            return true  // Prism mock requires Bearer token
        case .staging, .production:
            return true
        }
    }

    var mockAuthToken: String? {
        switch self {
        case .development:
            return "mock-dev-token"  // Only for Prism mock
        case .staging, .production:
            return nil  // Real auth required
        }
    }
}

class APIConfiguration {
    static let shared = APIConfiguration()

    // Determine environment based on build configuration
    #if DEBUG
    static let environment: APIEnvironment = .development
    #elseif STAGING
    static let environment: APIEnvironment = .staging
    #else
    static let environment: APIEnvironment = .production
    #endif

    // Thread-safe headers management
    private let queue = DispatchQueue(label: "com.englishbrain.api-config", attributes: .concurrent)
    private var _customHeaders: [String: String] = [:]

    private var customHeaders: [String: String] {
        get { queue.sync { _customHeaders } }
        set { queue.async(flags: .barrier) { [weak self] in self?._customHeaders = newValue } }
    }

    private init() {
        configure()
    }

    func configure() {
        let env = Self.environment

        // Set base URL
        EnglishBrainAPIAPI.basePath = env.baseURL

        // Set initial headers
        var headers: [String: String] = [:]

        // For development with mock server, use mock token
        if env == .development, let mockToken = env.mockAuthToken {
            headers["Authorization"] = "Bearer \(mockToken)"
        }

        customHeaders = headers
        EnglishBrainAPIAPI.customHeaders = headers

        print("✅ API configured:")
        print("   Environment: \(env)")
        print("   Base URL: \(EnglishBrainAPIAPI.basePath)")
        print("   Auth required: \(env.requiresAuth)")
    }

    func setAuthToken(_ token: String) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self._customHeaders["Authorization"] = "Bearer \(token)"
            DispatchQueue.main.async {
                EnglishBrainAPIAPI.customHeaders["Authorization"] = "Bearer \(token)"
                print("✅ Auth token updated")
            }
        }
    }

    func clearAuthToken() {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self._customHeaders.removeValue(forKey: "Authorization")
            DispatchQueue.main.async {
                EnglishBrainAPIAPI.customHeaders.removeValue(forKey: "Authorization")

                // Re-apply mock token if in development
                if Self.environment == .development,
                   let mockToken = Self.environment.mockAuthToken {
                    EnglishBrainAPIAPI.customHeaders["Authorization"] = "Bearer \(mockToken)"
                }
                print("✅ Auth token cleared")
            }
        }
    }
}
