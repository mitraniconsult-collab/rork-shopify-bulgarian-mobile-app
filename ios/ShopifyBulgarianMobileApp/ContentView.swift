import SwiftUI

struct ContentView: View {
    @State private var cartViewModel = CartViewModel()
    @State private var selectedTab: Int = 1
    @State private var showHome = true
    @State private var showSplash = true

    var body: some View {
        ZStack {
            Group {
                if showHome {
                    HomeView(cartViewModel: cartViewModel, onNavigateToTab: { tab in
                        selectedTab = tab
                        withAnimation(.easeInOut(duration: 0.25)) {
                            showHome = false
                        }
                    })
                    .transition(.asymmetric(
                        insertion: .identity,
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                } else {
                    tabbedView
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .identity
                        ))
                }
            }

            if showSplash {
                SplashView(isActive: $showSplash)
            }
        }
        .onAppear {
            configureTabBarAppearance()
        }
    }

    private var tabbedView: some View {
        TabView(selection: $selectedTab) {
            Tab("Категории", systemImage: "square.grid.2x2", value: 0) {
                CategoriesView(
                    cartViewModel: cartViewModel,
                    showHome: $showHome
                )
            }

            Tab("Кошница", systemImage: "bag", value: 1) {
                TabCartView(
                    cartViewModel: cartViewModel,
                    showHome: $showHome
                )
            }
            .badge(cartViewModel.itemCount)

            Tab("Профил", systemImage: "person", value: 2) {
                ProfileView(
                    cartViewModel: cartViewModel,
                    showHome: $showHome
                )
            }
        }
        .tint(HomeSectorDesign.Colors.accent)
    }

    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(HomeSectorDesign.Colors.tabBarBackground)
        appearance.shadowColor = UIColor(HomeSectorDesign.Colors.border)

        let normalAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10, weight: .regular),
            .foregroundColor: UIColor(HomeSectorDesign.Colors.tabBarInactive)
        ]
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10, weight: .regular),
            .foregroundColor: UIColor(HomeSectorDesign.Colors.accent)
        ]

        appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttributes
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttributes
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(HomeSectorDesign.Colors.tabBarInactive)
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(HomeSectorDesign.Colors.accent)

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

/// Wraps CartView inside a NavigationStack for the tab bar
private struct TabCartView: View {
    @Bindable var cartViewModel: CartViewModel
    @Binding var showHome: Bool

    var body: some View {
        NavigationStack {
            CartView(cartViewModel: cartViewModel, showHome: $showHome)
        }
    }
}
