//
//  ContentView.swift
//  EnglishBrain
//
//  Created by 이시현 on 10/4/25.
//

import SwiftUI
import EnglishBrainAPI

struct ContentView: View {
    @State private var status: String = "Ready to test API"
    @State private var isLoading: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "network")
                .imageScale(.large)
                .foregroundStyle(.tint)

            Text("EnglishBrain API Test")
                .font(.headline)

            Text(status)
                .multilineTextAlignment(.center)
                .padding()

            if isLoading {
                ProgressView()
            }

            Button("Test API Connection") {
                testAPI()
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLoading)
        }
        .padding()
    }

    func testAPI() {
        isLoading = true
        status = "Testing connection to http://localhost:3001..."

        UsersAPI.getHomeSummary { response, error in
            DispatchQueue.main.async {
                isLoading = false

                if let error = error {
                    status = "❌ Error: \(error.localizedDescription)"
                } else if let data = response {
                    status = "✅ Success!\n\nReceived data from API"
                } else {
                    status = "⚠️ No data received"
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
