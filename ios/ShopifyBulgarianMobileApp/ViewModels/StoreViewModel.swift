import SwiftUI

@Observable
final class StoreViewModel {
    var allProducts: [ShopifyProduct] = []
    var collections: [ShopifyCollection] = []
    var isLoading: Bool = false
    var productsError: String?
    var collectionsError: String?

    var sectionsLoaded: Bool { !allProducts.isEmpty || !collections.isEmpty }
    var hasErrors: Bool { productsError != nil || collectionsError != nil }

    func loadInitialData() async {
        guard allProducts.isEmpty && collections.isEmpty else { return }
        isLoading = true
        productsError = nil
        collectionsError = nil

        // Load collections independently
        Task {
            await loadCollections()
        }

        // Load products independently
        await loadProducts()

        isLoading = false
    }

    func loadCollections() async {
        do {
            collections = try await ShopifyService.shared.fetchCollectionsForHome(first: 20)
            collectionsError = nil
        } catch {
            collectionsError = error.localizedDescription
        }
    }

    func loadProducts() async {
        do {
            let result = try await ShopifyService.shared.fetchProductsFromCollection(
                handle: "allproducts",
                first: 10,
                sortKey: "BEST_SELLING"
            )
            allProducts = result.edges.map(\.node)
            productsError = nil
        } catch {
            productsError = error.localizedDescription
        }
    }

    func refreshAll() async {
        allProducts = []
        collections = []
        productsError = nil
        collectionsError = nil
        isLoading = true

        Task { await loadCollections() }
        await loadProducts()

        isLoading = false
    }
}
