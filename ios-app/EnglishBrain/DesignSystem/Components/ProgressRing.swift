//
//  ProgressRing.swift
//  EnglishBrain
//
//  Created by Claude on 10/4/25.
//

import SwiftUI

struct ProgressRing: View {
    let progress: Double // 0.0 to 1.0
    let lineWidth: CGFloat
    var size: CGFloat = 120
    var primaryColor: Color = .ebPrimary
    var backgroundColor: Color = .ebDivider

    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(backgroundColor, lineWidth: lineWidth)

            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    primaryColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    VStack(spacing: 30) {
        ProgressRing(progress: 0.75, lineWidth: 12, size: 120)
        ProgressRing(progress: 0.45, lineWidth: 8, size: 80, primaryColor: .ebSuccess)
    }
}
