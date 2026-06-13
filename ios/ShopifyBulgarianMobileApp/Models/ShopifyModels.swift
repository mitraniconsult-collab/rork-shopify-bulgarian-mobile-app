import Foundation

nonisolated struct GraphQLResponse<T: Decodable & Sendable>: Decodable, Sendable {
    let data: T?
    let errors: [GraphQLError]?
}

nonisolated struct GraphQLError: Decodable, Sendable {
    let message: String
}

nonisolated struct ProductsData: Decodable, Sendable {
    let products: Connection<ShopifyProduct>
}

nonisolated struct CollectionsData: Decodable, Sendable {
    let collections: Connection<ShopifyCollection>
}

nonisolated struct CollectionByHandleData: Decodable, Sendable {
    let collection: ShopifyCollection?
}

nonisolated struct CartCreateData: Decodable, Sendable {
    let cartCreate: CartCreatePayload
}

nonisolated struct CartCreatePayload: Decodable, Sendable {
    let cart: ShopifyCart?
    let userErrors: [CartUserError]?
}

nonisolated struct CartLinesAddData: Decodable, Sendable {
    let cartLinesAdd: CartLinesPayload
}

nonisolated struct CartLinesRemoveData: Decodable, Sendable {
    let cartLinesRemove: CartLinesPayload
}

nonisolated struct CartLinesUpdateData: Decodable, Sendable {
    let cartLinesUpdate: CartLinesPayload
}

nonisolated struct CartLinesPayload: Decodable, Sendable {
    let cart: ShopifyCart?
    let userErrors: [CartUserError]?
}

nonisolated struct CartUserError: Decodable, Sendable {
    let field: [String]?
    let message: String
}

nonisolated struct Connection<T: Decodable & Sendable>: Decodable, Sendable {
    let edges: [Edge<T>]
    let pageInfo: PageInfo?
}

nonisolated struct Edge<T: Decodable & Sendable>: Decodable, Sendable {
    let node: T
    let cursor: String?
}

nonisolated struct PageInfo: Decodable, Sendable {
    let hasNextPage: Bool?
    let hasPreviousPage: Bool?
}

// MARK: - Shopify Product

nonisolated struct ShopifyProduct: Decodable, Sendable, Identifiable {
    let id: String
    let title: String
    let handle: String
    let description: String?
    let productType: String?
    let vendor: String?
    let images: Connection<ShopifyImage>?
    let variants: Connection<ShopifyVariant>?
    let priceRange: PriceRange?

    var firstImage: ShopifyImage? {
        images?.edges.first?.node
    }

    var firstVariant: ShopifyVariant? {
        variants?.edges.first?.node
    }

    var safeDescription: String { description ?? "" }
}

// MARK: - Shopify Image

nonisolated struct ShopifyImage: Decodable, Sendable {
    let url: String?
    let altText: String?

    var imageURL: URL? {
        guard let url else { return nil }
        return URL(string: url)
    }
}

// MARK: - Shopify Variant

nonisolated struct ShopifyVariant: Decodable, Sendable, Identifiable {
    let id: String
    let title: String
    let price: MoneyV2?
    let availableForSale: Bool?
    let image: ShopifyImage?
    let selectedOptions: [SelectedOption]?
    let compareAtPrice: MoneyV2?

    var safePrice: MoneyV2 { price ?? MoneyV2.default }
    var safeAvailable: Bool { availableForSale ?? true }
    var safeCompareAtPrice: MoneyV2? { compareAtPrice }
}

nonisolated struct SelectedOption: Decodable, Sendable {
    let name: String?
    let value: String?
}

// MARK: - Money

nonisolated struct MoneyV2: Decodable, Sendable {
    let amount: String?
    let currencyCode: String?

    static let `default` = MoneyV2(amount: "0.00", currencyCode: "BGN")

    var safeAmount: String { amount ?? "0.00" }
    var safeCurrency: String { currencyCode ?? "BGN" }

    var formattedAmount: String {
        let value = Double(safeAmount) ?? 0
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = safeCurrency
        formatter.locale = Locale(identifier: "bg_BG")
        return formatter.string(from: NSNumber(value: value)) ?? "\(safeAmount) \(safeCurrency)"
    }
}

// MARK: - Price Range

nonisolated struct PriceRange: Decodable, Sendable {
    let minVariantPrice: MoneyV2?
    let maxVariantPrice: MoneyV2?

    var safeMinPrice: MoneyV2 { minVariantPrice ?? MoneyV2.default }
    var safeMaxPrice: MoneyV2 { maxVariantPrice ?? MoneyV2.default }
}

// MARK: - Shopify Collection

nonisolated struct ShopifyCollection: Decodable, Sendable, Identifiable {
    let id: String
    let title: String
    let handle: String
    let description: String?
    let image: ShopifyImage?
    let products: Connection<ShopifyProduct>?
}

// MARK: - Shopify Cart

nonisolated struct ShopifyCart: Decodable, Sendable, Identifiable {
    let id: String
    let checkoutUrl: String?
    let lines: Connection<CartLine>?
    let cost: CartCost?

    var totalQuantity: Int {
        lines?.edges.reduce(0) { $0 + ($1.node.quantity ?? 0) } ?? 0
    }

    var safeCheckoutUrl: String { checkoutUrl ?? "" }
    var safeLines: [CartLine] { lines?.edges.map(\.node) ?? [] }
}

nonisolated struct CartLine: Decodable, Sendable, Identifiable {
    let id: String
    let quantity: Int?
    let merchandise: CartMerchandise?
    let cost: CartLineCost?

    var safeQuantity: Int { quantity ?? 0 }
}

nonisolated struct CartMerchandise: Decodable, Sendable {
    let id: String
    let title: String
    let product: CartProduct?
    let image: ShopifyImage?
    let price: MoneyV2?

    var safePrice: MoneyV2 { price ?? MoneyV2.default }
}

nonisolated struct CartProduct: Decodable, Sendable {
    let title: String
    let handle: String
}

nonisolated struct CartLineCost: Decodable, Sendable {
    let totalAmount: MoneyV2?

    var safeTotal: MoneyV2 { totalAmount ?? MoneyV2.default }
}

nonisolated struct CartCost: Decodable, Sendable {
    let totalAmount: MoneyV2?
    let subtotalAmount: MoneyV2?
    let totalTaxAmount: MoneyV2?

    var safeTotal: MoneyV2 { totalAmount ?? MoneyV2.default }
    var safeSubtotal: MoneyV2 { subtotalAmount ?? MoneyV2.default }
    var safeTax: MoneyV2? { totalTaxAmount }
}

// MARK: - Fetch

nonisolated struct CartFetchData: Decodable, Sendable {
    let cart: ShopifyCart?
}

nonisolated struct ProductByHandleData: Decodable, Sendable {
    let product: ShopifyProduct?
}

// MARK: - Predictive Search

nonisolated struct PredictiveSearchProduct: Decodable, Sendable, Identifiable {
    let id: String
    let title: String
    let handle: String
    let vendor: String?
    let images: Connection<ShopifyImage>?
    let variants: Connection<ShopifyVariant>?
    let priceRange: PriceRange?

    var firstImage: ShopifyImage? {
        images?.edges.first?.node
    }

    var firstVariant: ShopifyVariant? {
        variants?.edges.first?.node
    }

    var safeMinPrice: MoneyV2 { priceRange?.safeMinPrice ?? MoneyV2.default }
}

nonisolated struct PredictiveSearchData: Decodable, Sendable {
    let predictiveSearch: PredictiveSearchResult?
}

nonisolated struct PredictiveSearchResult: Decodable, Sendable {
    let products: [PredictiveSearchProduct]?
}

// MARK: - Collection Products

nonisolated struct CollectionProductsData: Decodable, Sendable {
    let collection: CollectionProductsNode?
}

nonisolated struct CollectionProductsNode: Decodable, Sendable {
    let products: Connection<ShopifyProduct>
}
