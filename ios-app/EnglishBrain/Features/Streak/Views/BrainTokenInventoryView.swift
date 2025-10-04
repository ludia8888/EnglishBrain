//
//  BrainTokenInventoryView.swift
//  EnglishBrain
//
//  Created by Claude on 10/4/25.
//

import SwiftUI
import EnglishBrainAPI

struct BrainTokenInventoryView: View {
    @ObservedObject var viewModel: StreakViewModel
    @State private var showFreezeSheet = false
    @State private var selectedDate = Date()
    @State private var selectedReason: StreakFreezeRequest.Reason = .other

    var body: some View {
        VStack(spacing: 16) {
            headerView
            tokenInventory
            freezeButton
            pendingRequests
        }
        .padding()
        .background(Color.ebCard)
        .cornerRadius(16)
        .sheet(isPresented: $showFreezeSheet) {
            freezeSheetContent
        }
        .alert("프리즈 성공", isPresented: $viewModel.showFreezeSuccess) {
            Button("확인", role: .cancel) {}
        } message: {
            Text("스트릭이 성공적으로 보호되었습니다")
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Brain Token")
                    .font(.ebH4)
                    .foregroundColor(.ebTextPrimary)

                Text("스트릭 프리즈에 사용하세요")
                    .font(.ebCaption)
                    .foregroundColor(.ebTextSecondary)
            }

            Spacer()

            Image(systemName: "brain.head.profile")
                .font(.system(size: 32))
                .foregroundColor(.ebPrimary)
        }
    }

    // MARK: - Token Inventory

    private var tokenInventory: some View {
        HStack(spacing: 24) {
            tokenCard(
                title: "사용 가능",
                count: viewModel.brainTokens?.available ?? 0,
                icon: "checkmark.circle.fill",
                color: .ebSuccess
            )

            tokenCard(
                title: "획득 예정",
                count: viewModel.brainTokens?.pending ?? 0,
                icon: "clock.fill",
                color: .ebWarning
            )
        }
    }

    private func tokenCard(title: String, count: Int, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text("\(count)")
                    .font(.ebH2)
            }
            .foregroundColor(color)

            Text(title)
                .font(.ebCaption)
                .foregroundColor(.ebTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }

    // MARK: - Freeze Button

    private var freezeButton: some View {
        PrimaryButton(
            title: "스트릭 프리즈 사용",
            action: { showFreezeSheet = true },
            isEnabled: canUseFreeze
        )
    }

    private var canUseFreeze: Bool {
        guard let tokens = viewModel.brainTokens else { return false }
        guard let streak = viewModel.streak else { return false }
        return tokens.available > 0 && streak.freezeEligible
    }

    // MARK: - Pending Requests

    @ViewBuilder
    private var pendingRequests: some View {
        if !viewModel.pendingFreezeRequests.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .foregroundColor(.ebWarning)
                    Text("대기 중인 요청: \(viewModel.pendingFreezeRequests.count)개")
                        .font(.ebCaption)
                        .foregroundColor(.ebTextSecondary)

                    Spacer()

                    Button(action: {
                        viewModel.retryPendingFreezes()
                    }) {
                        Text("재시도")
                            .font(.ebCaption)
                            .foregroundColor(.ebPrimary)
                    }
                }
                .padding(12)
                .background(Color.ebWarning.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }

    // MARK: - Freeze Sheet

    private var freezeSheetContent: some View {
        NavigationView {
            VStack(spacing: 24) {
                headerSection

                datePickerSection

                reasonSection

                Spacer()

                confirmButton
            }
            .padding()
            .navigationTitle("스트릭 프리즈")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        showFreezeSheet = false
                    }
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "snowflake")
                .font(.system(size: 48))
                .foregroundColor(.ebInfo)

            Text("하루 쉬어도 스트릭이 유지됩니다")
                .font(.ebBody)
                .foregroundColor(.ebTextSecondary)
                .multilineTextAlignment(.center)

            HStack {
                Image(systemName: "brain.head.profile")
                Text("1 Brain Token 소모")
            }
            .font(.ebBodySmall)
            .foregroundColor(.ebPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.ebPrimary.opacity(0.1))
            .cornerRadius(8)
        }
    }

    private var datePickerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("프리즈 날짜")
                .font(.ebH5)
                .foregroundColor(.ebTextPrimary)

            DatePicker(
                "날짜 선택",
                selection: $selectedDate,
                in: Date()...Date().addingTimeInterval(86400 * 7),
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
        }
    }

    private var reasonSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("사유 (선택)")
                .font(.ebH5)
                .foregroundColor(.ebTextPrimary)

            VStack(spacing: 8) {
                reasonOption(.travel, "여행", "airplane")
                reasonOption(.illness, "건강", "cross.case")
                reasonOption(.workload, "업무", "briefcase")
                reasonOption(.other, "기타", "ellipsis.circle")
            }
        }
    }

    private func reasonOption(_ reason: StreakFreezeRequest.Reason, _ title: String, _ icon: String) -> some View {
        Button(action: {
            selectedReason = reason
        }) {
            HStack {
                Image(systemName: icon)
                    .frame(width: 24)
                Text(title)
                    .font(.ebBody)

                Spacer()

                if selectedReason == reason {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.ebPrimary)
                }
            }
            .foregroundColor(selectedReason == reason ? .ebPrimary : .ebTextPrimary)
            .padding()
            .background(
                selectedReason == reason ?
                    Color.ebPrimary.opacity(0.1) :
                    Color.ebDivider.opacity(0.3)
            )
            .cornerRadius(12)
        }
    }

    private var confirmButton: some View {
        VStack(spacing: 8) {
            if viewModel.freezeInProgress {
                ProgressView()
                    .scaleEffect(1.2)
            } else {
                PrimaryButton(
                    title: "프리즈 사용",
                    action: {
                        viewModel.freezeStreak(targetDate: selectedDate, reason: selectedReason)
                        showFreezeSheet = false
                    },
                    isEnabled: !viewModel.freezeInProgress
                )
            }

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.ebCaption)
                    .foregroundColor(.ebError)
            }
        }
    }
}
