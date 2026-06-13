import SwiftUI

enum HomeSectorDesign {

    // MARK: Colors
    enum Colors {
        static let background = Color(red: 1, green: 1, blue: 1)
        static let primaryText = Color(red: 0.102, green: 0.102, blue: 0.102)
        static let secondaryText = Color(red: 0.420, green: 0.420, blue: 0.420)
        static let accent = Color(red: 0.102, green: 0.102, blue: 0.102)
        static let saleRed = Color(red: 0.902, green: 0.212, blue: 0.278)
        static let struckGray = Color(red: 0.620, green: 0.620, blue: 0.620)
        static let border = Color(red: 0.933, green: 0.933, blue: 0.933)
        static let inputBackground = Color(red: 0.961, green: 0.961, blue: 0.961)
        static let tabBarBackground = Color(red: 1, green: 1, blue: 1)
        static let tabBarInactive = Color(red: 0.620, green: 0.620, blue: 0.620)
        static let white = Color.white
        static let black = Color.black
    }

    // MARK: Typography
    enum Typography {
        static func pageTitle(_ text: String) -> Text {
            Text(text).font(.system(size: 28, weight: .bold)).foregroundStyle(Colors.primaryText)
        }

        static func sectionHeader(_ text: String) -> Text {
            Text(text).font(.system(size: 17, weight: .semibold)).foregroundStyle(Colors.primaryText)
        }

        static func productTitle(_ text: String) -> Text {
            Text(text).font(.system(size: 15, weight: .medium)).foregroundStyle(Colors.primaryText)
        }

        static func productPrice(_ text: String) -> Text {
            Text(text).font(.system(size: 16, weight: .semibold)).foregroundStyle(Colors.primaryText)
        }

        static func bodyText(_ text: String) -> Text {
            Text(text).font(.system(size: 14, weight: .regular)).foregroundStyle(Colors.secondaryText)
        }

        static let tabLabelFont = Font.system(size: 10, weight: .regular)
    }

    // MARK: Layout
    enum Layout {
        static let cardCornerRadius: CGFloat = 12
        static let pillCornerRadius: CGFloat = 8
        static let horizontalPadding: CGFloat = 16
        static let sectionSpacing: CGFloat = 24
        static let gridSpacing: CGFloat = 12
        static let collectionCardWidth: CGFloat = 160
        static let collectionCardHeight: CGFloat = 100
    }
}
