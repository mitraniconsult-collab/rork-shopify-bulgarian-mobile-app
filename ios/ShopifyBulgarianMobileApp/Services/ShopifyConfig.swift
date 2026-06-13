import Foundation

enum ShopifyConfig {
    static let shopifyDomain = "homesectorr.myshopify.com"
    static let storefrontAccessToken = "76b19149929e0480c59282994059723e"
    static let apiVersion = "2024-07"
    static var storefrontURL: URL {
        URL(string: "https://\(shopifyDomain)/api/\(apiVersion)/graphql.json")!
    }
}
