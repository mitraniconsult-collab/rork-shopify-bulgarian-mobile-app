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
            .background(Color(.systemGray6))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Homesector")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color.primary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        NavigationLink {
                            SearchView(cartViewModel: cartViewModel)
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .font(.title3)
                                .foregroundStyle(Color.primary)
                        }
                        cartButton
                    }
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.white, for: .navigationBar)
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
        VStack(spacing: 0) {
            searchBar
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.white)

            heroBanner
                .padding(.top, 8)

            if !storeViewModel.collections.isEmpty {
                categoriesSection
            }

            if !saleProducts.isEmpty {
                saleSection
            }

            if !storeViewModel.allProducts.isEmpty {
                topProductsSection
                allProductsSection
            }
        }
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
                    .foregroundStyle(Color(.systemGray))
                Text("Търси продукти...")
                    .font(.system(size: 15))
                    .foregroundStyle(Color(.systemGray))
                Spacer()
            }
            .padding(.horizontal, 12)
            .frame(height: 42)
            .background(Color(.systemGray6))
            .clipShape(.rect(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Hero Banner

    private var heroBanner: some View {
        ZStack(alignment: .bottomLeading) {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#FF6000"), Color(hex: "#FF8C00")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 180)

            VStack(alignment: .leading, spacing: 6) {
                Text("Специални оферти")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
                Text("До -50% на избрани продукти")
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.9))
                Button {
                    onNavigateToTab(1)
                } label: {
                    Text("Виж офертите")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color(hex: "#FF6000"))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.white)
                        .clipShape(.rect(cornerRadius: 20))
                }
                .padding(.top, 4)
            }
            .padding(20)
        }
        .clipShape(.rect(cornerRadius: 16))
        .padding(.horizontal, 16)
    }

    // MARK: - Categories Section

    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Категории")
                    .font(.system(size: 17, weight: .semibold))
                Spacer()
                NavigationLink {
                    CategoriesView(cartViewModel: cartViewModel)
                } label: {
                    Text("Виж всички")
                        .font(.system(size: 13))
                        .foregroundStyle(Color(hex: "#FF6000"))
                }
            }
            .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(storeViewModel.collections) { collection in
                        NavigationLink(value: collection) {
                            categoryChip(collection)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.vertical, 16)
        .background(Color.white)
        .padding(.top, 8)
    }

    private func categoryChip(_ collection: ShopifyCollection) -> some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(Color(hex: "#FFF0E8"))
                    .frame(width: 52, height: 52)
                Image(systemName: categoryIcon(for: collection.title))
                    .font(.system(size: 22))
                    .foregroundStyle(Color(hex: "#FF6000"))
            }
            Text(collection.title)
                .font(.system(size: 11))
                .foregroundStyle(Color.primary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: 64)
        }
    }

    private func categoryIcon(for title: String) -> String {
        let t = title.lowercased()
        if t.contains("кухн") { return "fork.knife" }
        if t.contains("декор") { return "sparkles" }
        if t.contains("спалн") { return "bed.double" }
        if t.contains("баня") { return "shower" }
        if t.contains("детск") { return "teddybear" }
        if t.contains("градин") { return "leaf" }
        if t.contains("текстил") { return "rectangle.3.group" }
        if t.contains("съдов") || t.contains("готвен") { return "frying.pan" }
        if t.contains("дъск") || t.contains("нож") { return "scissors" }
        return "square.grid.2x2"
    }

    // MARK: - Sale Section

    private var saleProducts: [ShopifyProduct] {
        storeViewModel.allProducts.filter { product in
            guard let variant = product.variants.first,
                  let compareAt = variant.compareAtPrice,
                  let price = Double(variant.price),
                  let compare = Double(compareAt) else { return false }
            return compare > price
        }
    }

    private var saleSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "tag.fill")
                    .foregroundStyle(Color.red)
                Text("Намаления")
                    .font(.system(size: 17, weight: .semibold))
                Spacer()
                Text("Виж всички")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.red)
            }
            .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(saleProducts.prefix(10)) { product in
                        NavigationLink(value: product) {
                            saleProductCard(product)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.vertical, 16)
        .background(Color.white)
        .padding(.top, 8)
    }

    private func saleProductCard(_ product: ShopifyProduct) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack(alignment: .topLeading) {
                AsyncImage(url: URL(string: product.images.first?.url ?? "")) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color(.systemGray5)
                }
                .frame(width: 140, height: 140)
                .clipped()
                .clipShape(.rect(cornerRadius: 10))

                if let badge = discountBadge(for: product) {
                    Text(badge)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.red)
                        .clipShape(.rect(cornerRadius: 6))
                        .padding(6)
                }
            }

            Text(product.title)
                .font(.system(size: 12))
                .foregroundStyle(Color.primary)
                .lineLimit(2)
                .frame(width: 140, alignment: .leading)

            if let variant = product.variants.first {
                HStack(spacing: 4) {
                    Text("\(variant.price) лв.")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Color.red)
                    if let compareAt = variant.compareAtPrice {
                        Text("\(compareAt) лв.")
                            .font(.system(size: 11))
                            .foregroundStyle(Color(.systemGray))
                            .strikethrough()
                    }
                }
            }
        }
        .frame(width: 140)
    }

    private func discountBadge(for product: ShopifyProduct) -> String? {
        guard let variant = product.variants.first,
              let price = Double(variant.price),
              let compareAt = variant.compareAtPrice,
              let compare = Double(compareAt),
              compare > price else { return nil }
        let pct = Int(((compare - price) / compare) * 100)
        return "-\(pct)%"
    }

    // MARK: - Top Products Section

    private var topProductsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Топ продукти")
                    .font(.system(size: 17, weight: .semibold))
                Spacer()
            }
            .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(storeViewModel.allProducts.prefix(8)) { product in
                        NavigationLink(value: product) {
                            topProductCard(product)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.vertical, 16)
        .background(Color.white)
        .padding(.top, 8)
    }

    private func topProductCard(_ product: ShopifyProduct) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: product.images.first?.url ?? "")) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color(.systemGray5)
                }
                .frame(width: 130, height: 130)
                .clipped()
                .clipShape(.rect(cornerRadius: 10))

                Button {
                } label: {
                    Image(systemName: "heart")
                        .font(.system(size: 14))
                        .foregroundStyle(Color(.systemGray))
                        .padding(6)
                        .background(Color.white.opacity(0.9))
                        .clipShape(.circle)
                }
                .padding(6)
            }

            Text(product.title)
                .font(.system(size: 12))
                .foregroundStyle(Color.primary)
                .lineLimit(2)
                .frame(width: 130, alignment: .leading)

            if let variant = product.variants.first {
                Text("\(variant.price) лв.")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color(hex: "#FF6000"))
            }
        }
        .frame(width: 130)
    }

    // MARK: - All Products Section

    private var allProductsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Всички продукти")
                .font(.system(size: 17, weight: .semibold))
                .padding(.horizontal, 16)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ],
                spacing: 12
            ) {
                ForEach(storeViewModel.allProducts) { product in
                    NavigationLink(value: product) {
                        ProductCardView(product: product, cartViewModel: cartViewModel)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 16)
        .background(Color.white)
        .padding(.top, 8)
    }

    // MARK: - Cart Button

    private var cartButton: some View {
        Button {
            onNavigateToTab(1)
        } label: {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "bag")
                    .font(.title3)
                    .foregroundStyle(Color.primary)
                if cartViewModel.itemCount > 0 {
                    Text("\(cartViewModel.itemCount)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 18, height: 18)
                        .background(Color.red)
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
                .frame(height: 42)
                .clipShape(.rect(cornerRadius: 10))
                .padding(.horizontal, 16)
            Rectangle()
                .fill(Color(.systemGray6))
                .frame(height: 180)
                .clipShape(.rect(cornerRadius: 16))
                .padding(.horizontal, 16)
            ForEach(0..<2, id: \.self) { _ in
                HStack(spacing: 12) {
                    ForEach(0..<2, id: \.self) { _ in
                        skeletonCard
                    }
                }
                .padding(.horizontal, 16)
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
                .frame(height: 14, alignment: .leading)
                .frame(maxWidth: 80)
                .clipShape(.rect(cornerRadius: 4))
        }
    }
}

// MARK: - Color Hex Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
