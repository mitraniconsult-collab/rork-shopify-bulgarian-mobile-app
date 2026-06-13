import SwiftUI

@Observable
final class CollectionViewModel {
    var collection: ShopifyCollection?
    var products: [ShopifyProduct] = []
    var isLoading: Bool = false
    var errorMessage: String?
    var hasNextPage: Bool = false
    private var lastCursor: String?

    let handle: String

    init(handle: String) {
        self.handle = handle
    }

    func loadProducts() async {
        guard products.isEmpty else { return }
        isLoading = true
        errorMessage = nil

        do {
            let result = try await ShopifyService.shared.fetchCollectionProducts(handle: handle, first: 20)
            collection = result
            products = result?.products?.edges.map(\.node) ?? []
            hasNextPage = result?.products?.pageInfo?.hasNextPage ?? false
            lastCursor = result?.products?.edges.last?.cursor
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func loadMoreProducts() async {
        guard hasNextPage, let cursor = lastCursor, !isLoading else { return }
        isLoading = true

        do {
            let result = try await ShopifyService.shared.fetchCollectionProducts(handle: handle, first: 20, after: cursor)
            let newProducts = result?.products?.edges.map(\.node) ?? []
            products.append(contentsOf: newProducts)
            hasNextPage = result?.products?.pageInfo?.hasNextPage ?? false
            lastCursor = result?.products?.edges.last?.cursor
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
