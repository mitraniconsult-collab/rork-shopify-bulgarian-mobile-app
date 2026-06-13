import SwiftUI

struct HomeView: View {
    @State private var storeViewModel = StoreViewModel()
    @Bindable var cartViewModel: CartViewModel
    var onNavigateToTab: (Int) -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    if storeViewModel.isLoading && !storeViewModel.sectionsLoaded {
                        skeletonLoading
                    } else {
                        contentView
                    }
                }
            }
            .background(HomeSectorDesign.Colors.background)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        // Tap HomeSector to pop to root of this NavigationStack
                    } label: {
                        Text("HomeSector")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(HomeSectorDesign.Colors.primaryText)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    cartButton
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(HomeSectorDesign.Colors.background, for: .navigationBar)
            .refreshable {
                await storeViewModel.refreshAll()
            }
            .task {
                await storeViewModel.loadInitialData()
            }
            .navigationDestination(for: ShopifyProduct.self) { product in
                ProductDetailView(product: product, cartViewModel: cartViewModel)
            }
            .navigationDestination(for: ShopifyCollection.self) { collection in
                CollectionDetailView(handle: collection.handle, title: collection.title, cartViewModel: cartViewModel)
            }
        }
    }

    // MARK: - Content

    private var contentView: some View {
        VStack(spacing: HomeSectorDesign.Layout.sectionSpacing) {
            searchBar

            if !storeViewModel.collections.isEmpty {
                collectionsSection
            } else if storeViewModel.collectionsError != nil && storeViewModel.isLoading {
                // Silently skip — collection section just doesn't show
            }

            if !storeViewModel.allProducts.isEmpty {
                allProductsSection
            } else if storeViewModel.productsError != nil {
                // Show empty section with a subtle hint
                emptyProductsHint
            }

            if storeViewModel.sectionsLoaded && storeViewModel.allProducts.isEmpty && storeViewModel.collections.isEmpty && !storeViewModel.isLoading {
                emptyStoreHint
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 32)
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        NavigationLink {
            SearchView(cartViewModel: cartViewModel)
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 15))
                    .foregroundStyle(HomeSectorDesign.Colors.secondaryText)

                Text("Търсене на продукти...")
                    .font(.system(size: 15))
                    .foregroundStyle(HomeSectorDesign.Colors.secondaryText)

                Spacer()
            }
            .padding(.horizontal, 12)
            .frame(height: 44)
            .background(HomeSectorDesign.Colors.inputBackground)
            .clipShape(.rect(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, HomeSectorDesign.Layout.horizontalPadding)
    }

    // MARK: - Collections Section

    private var collectionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Колекции")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(HomeSectorDesign.Colors.primaryText)
                .padding(.horizontal, HomeSectorDesign.Layout.horizontalPadding)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(storeViewModel.collections) { collection in
                        NavigationLink(value: collection) {
                            CollectionCardView(collection: collection)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .contentMargins(.horizontal, HomeSectorDesign.Layout.horizontalPadding)
        }
    }

    // MARK: - All Products Section

    private var allProductsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Всички продукти")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(HomeSectorDesign.Colors.primaryText)
                .padding(.horizontal, HomeSectorDesign.Layout.horizontalPadding)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: HomeSectorDesign.Layout.gridSpacing),
                    GridItem(.flexible(), spacing: HomeSectorDesign.Layout.gridSpacing)
                ],
                spacing: 16
            ) {
                ForEach(storeViewModel.allProducts) { product in
                    NavigationLink(value: product) {
                        ProductCardView(product: product, cartViewModel: cartViewModel)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, HomeSectorDesign.Layout.horizontalPadding)
        }
    }

    // MARK: - Empty / Error hints

    private var emptyProductsHint: some View {
        VStack(spacing: 8) {
            Text("Продуктите не можаха да се заредят")
                .font(.system(size: 14))
                .foregroundStyle(HomeSectorDesign.Colors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, HomeSectorDesign.Layout.horizontalPadding)
        .padding(.vertical, 24)
    }

    private var emptyStoreHint: some View {
        ContentUnavailableView {
            Label("Няма намерени продукти", systemImage: "tray")
                .foregroundStyle(HomeSectorDesign.Colors.primaryText)
        } description: {
            Text("Опитайте отново по-късно")
                .foregroundStyle(HomeSectorDesign.Colors.secondaryText)
        }
        .frame(minHeight: 300)
    }

    // MARK: - Cart Button

    private var cartButton: some View {
        Button {
            onNavigateToTab(1)
        } label: {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "bag")
                    .font(.title3)
                    .foregroundStyle(HomeSectorDesign.Colors.primaryText)

                if cartViewModel.itemCount > 0 {
                    Text("\(cartViewModel.itemCount)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 18, height: 18)
                        .background(HomeSectorDesign.Colors.saleRed)
                        .clipShape(.circle)
                        .offset(x: 6, y: -6)
                }
            }
        }
    }

    // MARK: - Skeleton

    private var skeletonLoading: some View {
        VStack(spacing: 12) {
            Rectangle()
                .fill(Color(.systemGray6))
                .frame(height: 44)
                .clipShape(.rect(cornerRadius: 12))
                .padding(.horizontal, HomeSectorDesign.Layout.horizontalPadding)

            ForEach(0..<3, id: \.self) { _ in
                HStack(spacing: 12) {
                    ForEach(0..<2, id: \.self) { _ in
                        skeletonCard
                    }
                }
                .padding(.horizontal, HomeSectorDesign.Layout.horizontalPadding)
            }
        }
        .padding(.top, 8)
    }

    private var skeletonCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Rectangle()
                .fill(Color(.systemGray6))
                .aspectRatio(1, contentMode: .fit)
                .clipShape(.rect(cornerRadius: 12))
            Rectangle()
                .fill(Color(.systemGray6))
                .frame(height: 14)
                .clipShape(.rect(cornerRadius: 4))
            Rectangle()
                .fill(Color(.systemGray6))
                .frame(height: 14)
                .frame(width: 80)
                .clipShape(.rect(cornerRadius: 4))
        }
    }
}

extension ShopifyProduct: Hashable {
    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    nonisolated public static func == (lhs: ShopifyProduct, rhs: ShopifyProduct) -> Bool {
        lhs.id == rhs.id
    }
}

extension ShopifyCollection: Hashable {
    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    nonisolated public static func == (lhs: ShopifyCollection, rhs: ShopifyCollection) -> Bool {
        lhs.id == rhs.id
    }
}
