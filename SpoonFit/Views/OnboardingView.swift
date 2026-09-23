import SwiftUI

struct OnboardingView: View {
    let viewModel: ProgramViewModel

    @State private var page = 0
    @State private var clearance = false
    @State private var startDate = ProgramState.nextMonday()
    @State private var reminderEnabled = false
    @State private var reminderTime = Calendar.current.date(
        from: DateComponents(hour: 9, minute: 0)
    ) ?? Date()

    let theme = Theme.shared

    private let pageCount = 4

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                LanguagePill()
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)

            TabView(selection: $page) {
                welcomePage.tag(0)
                safetyPage.tag(1)
                materialPage.tag(2)
                startPage.tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            pageDots
                .padding(.vertical, 16)

            footer
                .padding(.horizontal, 20)
                .padding(.bottom, 18)
        }
        .background {
            ZStack {
                theme.background
                theme.backgroundWash
            }
            .ignoresSafeArea()
        }
    }

    // MARK: - Pages

    private var welcomePage: some View {
        page(icon: "figure.core.training", titleKey: "onboarding.welcomeTitle") {
            Text(t("onboarding.welcomeBody"))
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(theme.textDim)

            HStack(spacing: 10) {
                highlight("28", "tab.today")
                highlight("20", "params.minutes", raw: "min")
                highlight("4", "settings.reminders", raw: t("weekday.mon") + "–" + t("weekday.thu"))
            }
            .padding(.top, 6)
        }
    }

    private var safetyPage: some View {
        page(icon: "heart.text.square.fill", titleKey: "onboarding.safetyTitle") {
            ScrollView {
                SafetyCardView(compact: true)
            }
            .scrollIndicators(.hidden)
            .frame(maxHeight: 340)

            Toggle(isOn: $clearance.animation(theme.snappyAnimation)) {
                Text(t("onboarding.clearance"))
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(theme.text)
            }
            .tint(theme.ok)
            .padding(14)
            .panelBackground(elevated: true)
        }
    }

    private var materialPage: some View {
        page(icon: "shippingbox.fill", titleKey: "onboarding.materialTitle") {
            Text(t("onboarding.materialBody"))
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(theme.textDim)

            VStack(spacing: 10) {
                material("square.grid.3x3.fill", "material.mat")
                material("chair.fill", "material.chair")
                material("waterbottle.fill", "material.bottles")
                material("square.stack.3d.up.fill", "material.towel")
            }
        }
    }

    private var startPage: some View {
        page(icon: "calendar.badge.clock", titleKey: "onboarding.startTitle") {
            Text(t("onboarding.startBody"))
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(theme.textDim)

            VStack(spacing: 14) {
                DatePicker(
                    t("settings.startDate"),
                    selection: $startDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .tint(theme.accent)

                Divider().overlay(theme.accent.opacity(0.12))

                Toggle(isOn: $reminderEnabled.animation(theme.snappyAnimation)) {
                    Text(t("onboarding.reminderToggle"))
                        .font(.subheadline.weight(.medium))
                }
                .tint(theme.accent)

                if reminderEnabled {
                    DatePicker(
                        t("settings.reminderTime"),
                        selection: $reminderTime,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.compact)
                    .tint(theme.accent)
                }
            }
            .font(.subheadline)
            .foregroundStyle(theme.text)
            .padding(16)
            .panelBackground(elevated: true)
        }
    }

    // MARK: - Building blocks

    private func page<Content: View>(
        icon: String,
        titleKey: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        ScrollView {
            VStack(spacing: 18) {
                Image(systemName: icon)
                    .font(.system(size: 44))
                    .foregroundStyle(theme.accentGradient)
                    .padding(.top, 20)

                Text(t(titleKey))
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                    .foregroundStyle(theme.text)

                content()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 12)
        }
        .scrollIndicators(.hidden)
    }

    private func highlight(_ value: String, _ labelKey: String, raw: String? = nil) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.bold().monospacedDigit())
                .foregroundStyle(theme.accentGradient)
            Text(raw ?? t(labelKey))
                .font(.caption2)
                .multilineTextAlignment(.center)
                .foregroundStyle(theme.textDim)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(theme.panel)
        )
    }

    private func material(_ icon: String, _ key: String) -> some View {
        HStack(spacing: 13) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(theme.accent)
                .frame(width: 26)
                .symbolRenderingMode(.hierarchical)
            Text(t(key))
                .font(.subheadline)
                .foregroundStyle(theme.text)
            Spacer(minLength: 0)
        }
        .padding(14)
        .panelBackground()
    }

    private var pageDots: some View {
        HStack(spacing: 7) {
            ForEach(0..<pageCount, id: \.self) { index in
                Capsule()
                    .fill(index == page ? AnyShapeStyle(theme.accentGradient) : AnyShapeStyle(theme.panel2))
                    .frame(width: index == page ? 22 : 7, height: 7)
                    .animation(theme.snappyAnimation, value: page)
            }
        }
    }

    private var footer: some View {
        HStack(spacing: 12) {
            if page > 0 {
                OutlineButton(titleKey: "action.back", icon: "chevron.left") {
                    withAnimation(theme.springAnimation) { page -= 1 }
                }
                .frame(maxWidth: 130)
            }

            if page < pageCount - 1 {
                GradientButton(
                    titleKey: "action.next",
                    icon: "chevron.right",
                    isEnabled: page != 1 || clearance
                ) {
                    withAnimation(theme.springAnimation) { page += 1 }
                }
            } else {
                GradientButton(titleKey: "onboarding.start", icon: "sparkles") {
                    Haptics.success()
                    viewModel.startProgram(
                        startDate: Calendar.current.startOfDay(for: startDate),
                        reminderTime: reminderEnabled ? reminderTime : nil,
                        medicalClearance: clearance
                    )
                }
            }
        }
    }
}
