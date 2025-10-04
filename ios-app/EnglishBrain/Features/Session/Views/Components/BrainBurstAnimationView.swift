//
//  BrainBurstAnimationView.swift
//  EnglishBrain
//
//  Created by Claude on 10/4/25.
//

import SwiftUI

struct BrainBurstAnimationView: View {
    let multiplier: Double
    @State private var isAnimating = false
    @State private var pulseAnimation = false
    @State private var rotationAngle: Double = 0
    @State private var sparks: [SparkParticle] = []

    var body: some View {
        ZStack {
            // Background glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.yellow.opacity(0.6),
                            Color.orange.opacity(0.3),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 100
                    )
                )
                .frame(width: 200, height: 200)
                .scaleEffect(pulseAnimation ? 1.2 : 0.8)
                .opacity(pulseAnimation ? 0.8 : 0.4)

            // Lightning bolts
            ZStack {
                ForEach(0..<8) { index in
                    lightningBolt
                        .rotationEffect(.degrees(Double(index) * 45 + rotationAngle))
                        .opacity(isAnimating ? 1 : 0)
                        .animation(
                            .easeInOut(duration: 0.3)
                                .delay(Double(index) * 0.05),
                            value: isAnimating
                        )
                }
            }

            // Center brain icon
            ZStack {
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 80, height: 80)
                    .shadow(color: .yellow.opacity(0.5), radius: 20)

                Image(systemName: "brain.head.profile")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            .scaleEffect(pulseAnimation ? 1.1 : 1.0)

            // Multiplier badge
            VStack {
                Spacer()
                    .frame(height: 100)

                multiplierBadge
            }

            // Spark particles
            ForEach(sparks) { spark in
                sparkParticle(spark)
            }
        }
        .onAppear {
            startAnimation()
        }
    }

    // MARK: - Components

    private var lightningBolt: some View {
        ZStack {
            // Bolt path
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: -5, y: 25))
                path.addLine(to: CGPoint(x: 3, y: 25))
                path.addLine(to: CGPoint(x: -3, y: 50))
                path.addLine(to: CGPoint(x: 5, y: 50))
                path.addLine(to: CGPoint(x: 0, y: 80))
                path.addLine(to: CGPoint(x: 2, y: 50))
                path.addLine(to: CGPoint(x: -2, y: 50))
                path.addLine(to: CGPoint(x: 4, y: 25))
                path.addLine(to: CGPoint(x: -4, y: 25))
                path.closeSubpath()
            }
            .fill(
                LinearGradient(
                    colors: [.yellow, .orange],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .shadow(color: .yellow, radius: 4)
        }
        .offset(y: 40)
    }

    private var multiplierBadge: some View {
        Text("×\(String(format: "%.1f", multiplier))")
            .font(.system(size: 32, weight: .black))
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: .orange.opacity(0.6), radius: 10)
            )
            .scaleEffect(pulseAnimation ? 1.05 : 0.95)
    }

    private func sparkParticle(_ spark: SparkParticle) -> some View {
        Circle()
            .fill(Color.yellow)
            .frame(width: spark.size, height: spark.size)
            .position(spark.position)
            .opacity(spark.opacity)
    }

    // MARK: - Animations

    private func startAnimation() {
        // Main animations
        withAnimation(.easeInOut(duration: 0.5)) {
            isAnimating = true
        }

        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
            pulseAnimation = true
        }

        withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }

        // Spark particles
        generateSparks()
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            generateSparks()
        }
    }

    private func generateSparks() {
        let center = CGPoint(x: UIScreen.main.bounds.width / 2, y: 200)
        for _ in 0..<5 {
            let angle = Double.random(in: 0...(2 * .pi))
            let distance = Double.random(in: 40...100)
            let position = CGPoint(
                x: center.x + cos(angle) * distance,
                y: center.y + sin(angle) * distance
            )

            let spark = SparkParticle(
                id: UUID(),
                position: position,
                size: CGFloat.random(in: 2...6),
                opacity: Double.random(in: 0.5...1.0)
            )

            sparks.append(spark)

            // Remove spark after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                sparks.removeAll { $0.id == spark.id }
            }
        }
    }
}

// MARK: - Spark Particle

struct SparkParticle: Identifiable {
    let id: UUID
    var position: CGPoint
    var size: CGFloat
    var opacity: Double
}

// MARK: - Preview

struct BrainBurstAnimationView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            BrainBurstAnimationView(multiplier: 1.5)
        }
    }
}
