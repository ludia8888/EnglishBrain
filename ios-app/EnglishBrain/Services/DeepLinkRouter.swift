//
//  DeepLinkRouter.swift
//  EnglishBrain
//
//  Created by Claude on 10/4/25.
//

import Foundation
import SwiftUI

enum DeepLinkDestination: Equatable {
    case home
    case session(patternId: String?)
    case review(patternId: String?)
    case brainBurst
    case pattern(id: String)
    case profile
    case streak
    case unknown
}

@MainActor
class DeepLinkRouter: ObservableObject {
    @Published var activeDestination: DeepLinkDestination?

    /// Parse deep link URL and navigate to appropriate destination
    func handle(deeplink: String) {
        guard let url = URL(string: deeplink) else {
            print("❌ Invalid deep link: \(deeplink)")
            activeDestination = .unknown
            return
        }

        let path = url.path
        let components = path.split(separator: "/").map(String.init)
        let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems

        print("🔗 Handling deep link: \(deeplink)")
        print("Path: \(path), Components: \(components)")

        switch components.first {
        case "home":
            activeDestination = .home

        case "session":
            let patternId = queryItems?.first(where: { $0.name == "pattern" })?.value
            activeDestination = .session(patternId: patternId)

        case "review":
            let patternId = queryItems?.first(where: { $0.name == "pattern" })?.value
            activeDestination = .review(patternId: patternId)

        case "brain-burst":
            activeDestination = .brainBurst

        case "pattern":
            if components.count > 1 {
                activeDestination = .pattern(id: components[1])
            } else {
                activeDestination = .unknown
            }

        case "profile":
            activeDestination = .profile

        case "streak":
            activeDestination = .streak

        default:
            print("⚠️ Unhandled deep link path: \(path)")
            activeDestination = .unknown
        }
    }

    func reset() {
        activeDestination = nil
    }
}
