import SwiftUI

struct SearchView: View {
    @Bindable var cartViewModel: CartViewModel

    @State private var searchText: String = ""
    @State private var results: [PredictiveSearchProduct] = []
    @State private var isSearching: Bool = false
    @State private var hasSearched: Bool = false
    @State private var productToShow: ShopifyProduct?
    @State private var isLoadingProduct: Bool = false
    @State private var searchTask: Task<Void, Never>?

    @FocusState private var isFocused: Bool

    var body: some View {
        List {
            if isSearching {
                HStack {
                    Spacer()
                    ProgressView()
                        .padding(.vertical, 32)
                    Spacer()
                }
                .listRowSeparator(.hidden)
                .listRowBackground(HomeSectorDesign.Colors.background)
            } else if hasSearched && results.isEmpty {
                ContentUnavailableView(
                    "Няма резултати",
                    systemImage: "magnifyingglass",
                    description: Text("Опитайте с друга ключова дума")
                        .foregroundStyle(HomeSectorDesign.Colors.secondaryText)
                )
                .listRowSeparator(.hidden)
                .listRowBackground(HomeSectorDesign.Colors.background)
            } else {
                ForEach(results) { result in
                    Button {
                        fetchAndNavigate(handle: result.handle)
                    } label: {
                        SearchResultCard(result: result)
                    }
                    .buttonStyle(.plain)
                    .disabled(isLoadingProduct)
                    .listRowBackground(HomeSectorDesign.Colors.background)
                    .listRowSeparatorTint(HomeSectorDesign.Colors.border)
                }
            }

            if isLoadingProduct {
                HStack {
                    Spacer()
                    ProgressView()
                        .padding(.vertical, 16)
                    Spacer()
                }
                .listRowSeparator(.hidden)
                .listRowBackground(HomeSectorDesign.Colors.background)
            }
        }
        .listStyle(.plain)
        .background(HomeSectorDesign.Colors.background)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(HomeSectorDesign.Colors.background, for: .navigationBar)
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Търсене на продукти..."
        )
        .onChange(of: searchText) { _, newValue in
            performSearch(query: newValue)
        }
        .onAppear {
            isFocused = true
        }
        .navigationDestination(item: $productToShow) { product in
            ProductDetailView(product: product, cartViewModel: cartViewModel)
        }
    }

    private func performSearch(query: String) {
        searchTask?.cancel()

        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            results = []
            hasSearched = false
            isSearching = false
            return
        }

        isSearching = true

        searchTask = Task {
            do {
                try await Task.sleep(for: .milliseconds(400))
                guard !Task.isCancelled else { return }

                let searchResults = try await ShopifyService.shared.predictiveSearch(query: trimmed, limit: 10)
                guard !Task.isCancelled else { return }

                results = searchResults
                hasSearched = true
                isSearching = false
            } catch {
                guard !Task.isCancelled else { return }
                results = []
                hasSearched = true
                isSearching = false
            }
        }
    }

    private func fetchAndNavigate(handle: String) {
        isLoadingProduct = true
        Task {
            let product = try? await ShopifyService.shared.fetchProductByHandle(handle: handle)
            guard !Task.isCancelled else { return }
            productToShow = product
            isLoadingProduct = false
        }
    }
}

private struct SearchResultCard: View {
    let result: PredictiveSearchProduct

    private var displayPrice: String {
        result.safeMinPrice.formattedAmount
    }

    private var hasSale: Bool {
        guard let compareAt = result.firstVariant?.compareAtPrice,
              let compareValue = Double(compareAt.safeAmount),
              let currentValue = Double(result.priceRange?.safeMinPrice.safeAmount ?? "0") else { return false }
        return compareValue > currentValue
    }

    var body: some View {
        HStack(spacing: 12) {
            Color(.systemGray6)
                .frame(width: 64, height: 64)
                .overlay {
                    if let imageURL = result.firstImage?.imageURL {
                        AsyncImage(url: imageURL) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            case .failure:
                                Image(systemName: "photo")
                                    .font(.title3)
                                    .foregroundStyle(Color(.systemGray4))
                            default:
                                Rectangle()
                                    .fill(Color(.systemGray6))
                            }
                        }
                        .allowsHitTesting(false)
                    } else {
                        Image(systemName: "photo")
                            .font(.title3)
                            .foregroundStyle(Color(.systemGray4))
                    }
                }
                .clipShape(.rect(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(result.title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(HomeSectorDesign.Colors.primaryText)
                    .lineLimit(2)

                HStack(spacing: 6) {
                    if hasSale, let compareAt = result.firstVariant?.compareAtPrice {
                        Text(displayPrice)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(HomeSectorDesign.Colors.saleRed)
                        Text(compareAt.formattedAmount)
                            .font(.system(size: 13))
                            .foregroundStyle(HomeSectorDesign.Colors.struckGray)
                            .strikethrough()
                    } else {
                        Text(displayPrice)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(HomeSectorDesign.Colors.primaryText)
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundStyle(HomeSectorDesign.Colors.secondaryText)
        }
        .padding(.vertical, 4)
    }
}
