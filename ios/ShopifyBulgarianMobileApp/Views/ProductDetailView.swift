import SwiftUI

struct ProductDetailView: View {
    let product: ShopifyProduct
    @Bindable var cartViewModel: CartViewModel

    @State private var selectedVariant: ShopifyVariant?
    @State private var selectedImageIndex: Int = 0
    @State private var isAddingToCart: Bool = false
    @State private var showAddedFeedback: Bool = false
    @State private var isDescriptionExpanded: Bool = false
    @State private var relatedProducts: [ShopifyProduct] = []

    private var images: [ShopifyImage] {
        product.images?.edges.map(\.node) ?? []
    }

    private var variants: [ShopifyVariant] {
        product.variants?.edges.map(\.node) ?? []
    }

    private var selectedPrice: String {
        selectedVariant?.safePrice.formattedAmount ?? product.priceRange?.safeMinPrice.formattedAmount ?? ""
    }

    private var hasSale: Bool {
        guard let variant = selectedVariant,
              let compareAt = variant.compareAtPrice,
              let compareValue = Double(compareAt.safeAmount),
              let currentValue = Double(variant.safePrice.safeAmount) else { return false }
        return compareValue > currentValue
    }

    private var isAvailable: Bool {
        selectedVariant?.safeAvailable ?? true
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 0) {
                    imageGallery

                    VStack(alignment: .leading, spacing: 16) {
                        productInfo

                        deliveryInfo

                        if variants.count > 1 {
                            variantPicker
                        }

                        Divider()
                            .overlay(HomeSectorDesign.Colors.border)

                        descriptionSection

                        Divider()
                            .overlay(HomeSectorDesign.Colors.border)

                        guaranteeSection
                    }
                    .padding(20)
                    .background(HomeSectorDesign.Colors.background)

                    if !relatedProducts.isEmpty {
                        relatedProductsSection
                            .padding(.top, 8)
                    }

                    Spacer().frame(height: 100)
                }
            }
            .background(Color(.systemGray6))

            addToCartButton
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(HomeSectorDesign.Colors.background, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                wishlistToolbarButton
            }
        }
        .onAppear {
            selectedVariant = product.firstVariant
            loadRelatedProducts()
        }
        .sensoryFeedback(.success, trigger: showAddedFeedback)
    }

    // MARK: - Image Gallery

    private var imageGallery: some View {
        ZStack(alignment: .bottom) {
            if images.isEmpty {
                Color(.systemGray6)
                    .aspectRatio(1, contentMode: .fit)
                    .overlay {
                        Image(systemName: "photo")
                            .font(.system(size: 48))
                            .foregroundStyle(Color(.systemGray4))
                    }
            } else {
                TabView(selection: $selectedImageIndex) {
                    ForEach(Array(images.enumerated()), id: \.offset) { index, shopifyImage in
                        if let url = shopifyImage.imageURL {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                case .failure:
                                    Color(.systemGray6)
                                        .overlay {
                                            Image(systemName: "photo")
                                                .font(.system(size: 48))
                                                .foregroundStyle(Color(.systemGray4))
                                        }
                                default:
                                    Color(.systemGray6)
                                }
                            }
                            .tag(index)
                        }
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: UIScreen.main.bounds.width)
            }

            if images.count > 1 {
                HStack(spacing: 6) {
                    ForEach(0..<images.count, id: \.self) { index in
                        Circle()
                            .fill(index == selectedImageIndex ? Color(hex: "#FF6000") : Color.white.opacity(0.6))
                            .frame(
                                width: index == selectedImageIndex ? 8 : 6,
                                height: index == selectedImageIndex ? 8 : 6
                            )
                    }
                }
                .padding(.bottom, 12)
            }
        }
    }

    // MARK: - Product Info

    private var productInfo: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(product.title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(HomeSectorDesign.Colors.primaryText)

            HStack(spacing: 8) {
                Text(selectedPrice)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(hasSale ? Color.red : Color(hex: "#FF6000"))

                if hasSale,
                   let variant = selectedVariant,
                   let compareAt = variant.compareAtPrice {
                    Text(compareAt.formattedAmount)
                        .font(.system(size: 15))
                        .foregroundStyle(Color(.systemGray))
                        .strikethrough()

                    if let compareValue = Double(compareAt.safeAmount),
                       let currentValue = Double(variant.safePrice.safeAmount) {
                        let discount = Int(((compareValue - currentValue) / compareValue) * 100)
                        Text("-\(discount)%")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.red)
                            .clipShape(.rect(cornerRadius: 6))
                    }
                }
            }

            if let variant = selectedVariant {
                HStack(spacing: 6) {
                    Circle()
                        .fill(variant.safeAvailable ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                    Text(variant.safeAvailable ? "В наличност" : "Изчерпан")
                        .font(.system(size: 13))
                        .foregroundStyle(variant.safeAvailable ? Color.green : Color.red)
                }
            }
        }
    }

    // MARK: - Delivery Info

    private var deliveryInfo: some View {
        VStack(spacing: 0) {
            deliveryRow(
                icon: "shippingbox.fill",
                iconColor: Color(hex: "#FF6000"),
                title: "Бърза доставка",
                subtitle: "1-3 работни дни"
            )
            Divider().padding(.leading, 44)
            deliveryRow(
                icon: "arrow.uturn.left",
                iconColor: Color.blue,
                title: "Лесно връщане",
                subtitle: "До 14 дни след получаване"
            )
            Divider().padding(.leading, 44)
            deliveryRow(
                icon: "creditcard.fill",
                iconColor: Color.green,
                title: "Сигурно плащане",
                subtitle: "Карта, наложен платеж"
            )
        }
        .background(Color(.systemGray6))
        .clipShape(.rect(cornerRadius: 12))
    }

    private func deliveryRow(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(iconColor)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(HomeSectorDesign.Colors.primaryText)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(HomeSectorDesign.Colors.secondaryText)
            }
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    // MARK: - Variant Picker

    private var variantPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Вариант")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(HomeSectorDesign.Colors.primaryText)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(variants) { variant in
                        Button {
                            selectedVariant = variant
                        } label: {
                            Text(variant.title)
                                .font(.system(size: 14, weight: .medium))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(
                                    selectedVariant?.id == variant.id
                                        ? Color(hex: "#FF6000")
                                        : HomeSectorDesign.Colors.background
                                )
                                .foregroundStyle(
                                    selectedVariant?.id == variant.id
                                        ? .white
                                        : HomeSectorDesign.Colors.primaryText
                                )
                                .clipShape(.rect(cornerRadius: HomeSectorDesign.Layout.pillCornerRadius))
                                .overlay(
                                    RoundedRectangle(cornerRadius: HomeSectorDesign.Layout.pillCornerRadius)
                                        .stroke(
                                            selectedVariant?.id == variant.id
                                                ? Color.clear
                                                : HomeSectorDesign.Colors.border,
                                            lineWidth: 1
                                        )
                                )
                                .opacity(variant.safeAvailable ? 1 : 0.35)
                        }
                        .disabled(!variant.safeAvailable)
                    }
                }
            }
        }
    }

    // MARK: - Description

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !strippedDescription.isEmpty {
                Text("Описание")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(HomeSectorDesign.Colors.primaryText)

                Text(isDescriptionExpanded ? fullStrippedDescription : shortStrippedDescription)
                    .font(.system(size: 14))
                    .foregroundStyle(HomeSectorDesign.Colors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)

                if fullStrippedDescription.count > 300 {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isDescriptionExpanded.toggle()
                        }
                    } label: {
                        Text(isDescriptionExpanded ? "Скрий" : "Виж повече")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color(hex: "#FF6000"))
                    }
                }
            }
        }
    }

    // MARK: - Guarantee Section

    private var guaranteeSection: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 24))
                .foregroundStyle(Color(hex: "#FF6000"))
            VStack(alignment: .leading, spacing: 2) {
                Text("Гаранция за качество")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(HomeSectorDesign.Colors.primaryText)
                Text("Всички продукти са с гаранция")
                    .font(.system(size: 12))
                    .foregroundStyle(HomeSectorDesign.Colors.secondaryText)
            }
            Spacer()
        }
        .padding(14)
        .background(Color(hex: "#FFF0E8"))
        .clipShape(.rect(cornerRadius: 12))
    }

    // MARK: - Related Products

    private func loadRelatedProducts() {
        let allProducts = StoreViewModel.shared?.allProducts ?? []
        relatedProducts = allProducts
            .filter { $0.id != product.id }
            .prefix(8)
            .map { $0 }
    }

    private var relatedProductsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Подобни продукти")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(HomeSectorDesign.Colors.primaryText)
                .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(relatedProducts) { related in
                        NavigationLink(value: related) {
                            relatedProductCard(related)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.vertical, 16)
        .background(Color.white)
    }

    private func relatedProductCard(_ product: ShopifyProduct) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            AsyncImage(url: URL(string: product.images?.edges.first?.node.url ?? "")) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Color(.systemGray5)
            }
            .frame(width: 130, height: 130)
            .clipped()
            .clipShape(.rect(cornerRadius: 10))

            Text(product.title)
                .font(.system(size: 12))
                .foregroundStyle(Color.primary)
                .lineLimit(2)
                .frame(width: 130, alignment: .leading)

            if let variant = product.variants?.edges.first?.node {
                Text("\(variant.price.amount) лв.")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color(hex: "#FF6000"))
            }
        }
        .frame(width: 130)
    }

    // MARK: - Description Helpers

    private var fullStrippedDescription: String {
        product.safeDescription
            .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#39;", with: "'")
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var strippedDescription: String {
        fullStrippedDescription
    }

    private var shortStrippedDescription: String {
        let full = fullStrippedDescription
        guard full.count > 300 else { return full }
        let endIndex = full.index(full.startIndex, offsetBy: 300)
        return String(full[..<endIndex]) + "..."
    }

    // MARK: - Wishlist

    private var wishlistToolbarButton: some View {
        Button {
            cartViewModel.toggleWishlist(product: product)
        } label: {
            Image(systemName: cartViewModel.isInWishlist(productId: product.id) ? "heart.fill" : "heart")
                .font(.system(size: 18))
                .foregroundStyle(
                    cartViewModel.isInWishlist(productId: product.id)
                        ? Color.red
                        : HomeSectorDesign.Colors.primaryText
                )
        }
    }

    // MARK: - Add to Cart

    private var addToCartButton: some View {
        VStack(spacing: 0) {
            Divider()
                .overlay(HomeSectorDesign.Colors.border)

            HStack(spacing: 12) {
                Button {
                    cartViewModel.toggleWishlist(product: product)
                } label: {
                    Image(systemName: cartViewModel.isInWishlist(productId: product.id) ? "heart.fill" : "heart")
                        .font(.system(size: 20))
                        .foregroundStyle(
                            cartViewModel.isInWishlist(productId: product.id)
                                ? Color.red
                                : HomeSectorDesign.Colors.primaryText
                        )
                        .frame(width: 52, height: 52)
                        .background(Color(.systemGray6))
                        .clipShape(.rect(cornerRadius: 12))
                }

                Button {
                    guard let variant = selectedVariant, variant.safeAvailable else { return }
                    isAddingToCart = true
                    Task {
                        await cartViewModel.addToCart(variantId: variant.id)
                        isAddingToCart = false
                        showAddedFeedback.toggle()
                    }
                } label: {
                    HStack(spacing: 8) {
                        if isAddingToCart {
                            ProgressView().tint(.white)
                        } else {
                            Image(systemName: "bag.badge.plus")
                                .font(.system(size: 16))
                            Text(showAddedFeedback ? "Добавено!" : "Добави в кошницата")
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        isAvailable && !isAddingToCart
                            ? Color(hex: "#FF6000")
                            : Color(.systemGray4)
                    )
                    .foregroundStyle(.white)
                    .clipShape(.rect(cornerRadius: 12))
                }
                .disabled(!isAvailable || isAddingToCart)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(HomeSectorDesign.Colors.background)
    }
}
