//
//  PrimaryButton.swift
//  EnglishBrain
//
//  Created by Claude on 10/4/25.
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isEnabled: Bool = true
    var isLoading: Bool = false
    var style: ButtonStyle = .primary

    enum ButtonStyle {
        case primary
        case secondary
        case outline

        var backgroundColor: Color {
            switch self {
            case .primary: return .ebPrimary
            case .secondary: return .ebPrimaryLight
            case .outline: return .clear
            }
        }

        var foregroundColor: Color {
            switch self {
            case .primary, .secondary: return .white
            case .outline: return .ebPrimary
            }
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: style.foregroundColor))
                        .scaleEffect(0.8)
                }
                Text(title)
                    .font(.ebButton)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .foregroundColor(style.foregroundColor)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(style.backgroundColor)
                    .opacity(isEnabled ? 1.0 : 0.5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(style == .outline ? Color.ebPrimary : Color.clear, lineWidth: 2)
            )
        }
        .disabled(!isEnabled || isLoading)
    }
}

#Preview {
    VStack(spacing: 20) {
        PrimaryButton(title: "Primary Button", action: {})
        PrimaryButton(title: "Loading", action: {}, isLoading: true)
        PrimaryButton(title: "Disabled", action: {}, isEnabled: false)
        PrimaryButton(title: "Secondary", action: {}, style: .secondary)
        PrimaryButton(title: "Outline", action: {}, style: .outline)
    }
    .padding()
}
