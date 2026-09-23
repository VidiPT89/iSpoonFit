import SwiftData
import SwiftUI

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var systemColorScheme

    @State private var viewModel = ProgramViewModel()
    @State private var showSplash = true

    let theme = Theme.shared

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()

            if showSplash {
                SplashView {
                    withAnimation(.easeInOut(duration: 0.45)) { showSplash = false }
                }
                .transition(.opacity)
            } else if !viewModel.hasOnboarded {
                OnboardingView(viewModel: viewModel)
                    .transition(.asymmetric(
                        insertion: .opacity,
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            } else {
                MainTabView(viewModel: viewModel)
                    .transition(.opacity.combined(with: .scale(scale: 1.02)))
            }
        }
        .preferredColorScheme(theme.preferredColorScheme)
        .animation(theme.springAnimation, value: viewModel.hasOnboarded)
        .onAppear {
            theme.systemIsDark = systemColorScheme == .dark
            viewModel.load(context: modelContext)
        }
        .onChange(of: LocalizationManager.shared.current) { _, _ in
            viewModel.refreshReminderLanguage()
        }
        .onChange(of: systemColorScheme) { _, newValue in
            withAnimation(.easeInOut(duration: 0.3)) {
                theme.systemIsDark = newValue == .dark
            }
        }
    }
}
