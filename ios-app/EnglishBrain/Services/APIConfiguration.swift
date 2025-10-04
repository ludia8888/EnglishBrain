//
//  APIConfiguration.swift
//  EnglishBrain
//
//  Created by Claude on 10/4/25.
//

import Foundation
import EnglishBrainAPI

class APIConfiguration {
    static let shared = APIConfiguration()

    private init() {
        configure()
    }

    func configure() {
        // Base URL
        EnglishBrainAPIAPI.basePath = "http://127.0.0.1:3001"

        // Mock auth token for development (Prism requires Bearer token)
        EnglishBrainAPIAPI.customHeaders = [
            "Authorization": "Bearer mock-dev-token"
        ]

        print("✅ API configured:")
        print("   Base URL: \(EnglishBrainAPIAPI.basePath)")
        print("   Headers: \(EnglishBrainAPIAPI.customHeaders)")
    }

    func setAuthToken(_ token: String) {
        EnglishBrainAPIAPI.customHeaders["Authorization"] = "Bearer \(token)"
    }

    func clearAuthToken() {
        EnglishBrainAPIAPI.customHeaders.removeValue(forKey: "Authorization")
    }
}
