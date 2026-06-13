import SwiftUI

@main
struct ShopifyBulgarianMobileAppApp: App {
    init() {
        configureGlobalAppearance()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    private func configureGlobalAppearance() {
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = UIColor(HomeSectorDesign.Colors.background)
        navAppearance.shadowColor = .clear
        navAppearance.titleTextAttributes = [
            .foregroundColor: UIColor(HomeSectorDesign.Colors.primaryText)
        ]
        navAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(HomeSectorDesign.Colors.primaryText)
        ]

        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance
    }
}
