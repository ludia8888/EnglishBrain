//
//  AppEnvironment.swift
//  EnglishBrain
//
//  Created by Codex on 10/5/25.
//

import Foundation

@MainActor
final class AppEnvironment {
    static let shared = AppEnvironment()

    enum DataSource {
        case mock
        case live
    }

    private let overrideKey = "com.englishbrain.environment.dataSource"
    private(set) var dataSource: DataSource

    var usesMockData: Bool {
        dataSource == .mock
    }

    private init() {
#if DEBUG
        if let stored = UserDefaults.standard.string(forKey: overrideKey),
           let dataSource = DataSource(storedValue: stored) {
            self.dataSource = dataSource
        } else {
            self.dataSource = .mock
        }
#else
        self.dataSource = .live
#endif
    }

    func useMockData() {
        updateDataSource(.mock)
    }

    func useLiveAPI() {
        updateDataSource(.live)
    }

    private func updateDataSource(_ source: DataSource) {
        dataSource = source
#if DEBUG
        UserDefaults.standard.set(source.storedValue, forKey: overrideKey)
#endif
    }
}

private extension AppEnvironment.DataSource {
    init?(storedValue: String) {
        switch storedValue {
        case "mock":
            self = .mock
        case "live":
            self = .live
        default:
            return nil
        }
    }

    var storedValue: String {
        switch self {
        case .mock:
            return "mock"
        case .live:
            return "live"
        }
    }
}
