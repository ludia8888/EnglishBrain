//
//  EnglishBrainApp.swift
//  EnglishBrain
//
//  Created by 이시현 on 10/4/25.
//

import SwiftUI
import EnglishBrainAPI

@main
struct EnglishBrainApp: App {
    init() {
        // Configure API base path
        EnglishBrainAPIAPI.basePath = "http://localhost:3001"
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
