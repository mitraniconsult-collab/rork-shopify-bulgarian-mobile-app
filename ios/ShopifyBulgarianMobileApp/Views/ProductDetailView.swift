import SwiftUI

struct ProductDetailView: View {
    let product: ShopifyProduct
    @Bindable var cartViewModel: CartViewModel

    @State private var selectedVariant: ShopifyVariant?
    @State private var selectedImageIndex: Int = 0
    @State private var isAddingToCart: Bool = false
    @State private var showAddedFeedback: Bool = false
    @State private var isDescriptionExpanded: Bool = false

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

                        if variants.count > 1 {
                            variantPicker
                        }

                        Divider()
                            .overlay(HomeSectorDesign.Colors.border)

                        descriptionSection
                    }
                    .padding(20)
                    .background(HomeSectorDesign.Colors.background)
                }
            }
            .background(HomeSectorDesign.Colors.background)

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
        }
        .sensoryFeedback(.success, trigger: showAddedFeedback)
    }

    // MARK: - Image Gallery

    private var imageGallery: some View {
        ZStack(alignment: .bottomTrailing) {
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
                Text("\(selectedImageIndex + 1)/\(images.count)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.black.opacity(0.5))
                    .clipShape(.rect(cornerRadius: 12))
                    .padding(12)
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
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(hasSale ? HomeSectorDesign.Colors.saleRed : HomeSectorDesign.Colors.primaryText)

                if hasSale,
                   let variant = selectedVariant,
                   let compareAt = variant.compareAtPrice {
                    Text(compareAt.formattedAmount)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(HomeSectorDesign.Colors.struckGray)
                        .strikethrough()

                    if let compareValue = Double(compareAt.safeAmount),
                       let currentValue = Double(variant.safePrice.safeAmount) {
                        let discount = Int(((compareValue - currentValue) / compareValue) * 100)
                        Text("-\(discount)%")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(HomeSectorDesign.Colors.saleRed)
                            .clipShape(.rect(cornerRadius: 4))
                    }
                }
            }

            if let variant = selectedVariant {
                HStack(spacing: 4) {
                    Circle()
                        .fill(variant.safeAvailable ? Color.green : HomeSectorDesign.Colors.saleRed)
                        .frame(width: 7, height: 7)
                    Text(variant.safeAvailable ? "В наличност" : "Изчерпан")
                        .font(.system(size: 13))
                        .foregroundStyle(variant.safeAvailable ? Color.green : HomeSectorDesign.Colors.saleRed)
                }
            }
        }
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
                                        ? HomeSectorDesign.Colors.accent
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
                                            selectedVariant?.id == variant.id ? Color.clear : HomeSectorDesign.Colors.border,
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
                    .font(.system(size: 14, weight: .regular))
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
                            .foregroundStyle(HomeSectorDesign.Colors.accent)
                    }
                }
            }
        }
    }

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
            .replacingOccurrences(of: "\n{2,}", with: "\n\n", options: .regularExpression)
    }

    private var strippedDescription: String {
        let full = fullStrippedDescription
        if isDescriptionExpanded || full.count <= 300 { return full }
        let endIndex = full.index(full.startIndex, offsetBy: min(300, full.count))
        return String(full[..<endIndex]) + "..."
    }

    private var shortStrippedDescription: String {
        let full = fullStrippedDescription
        if full.count <= 300 { return full }
        let endIndex = full.index(full.startIndex, offsetBy: min(300, full.count))
        return String(full[..<endIndex]) + "..."
    }

    // MARK: - Wishlist

    private var wishlistToolbarButton: some View {
        Button {
            cartViewModel.toggleWishlist(product: product)
        } label: {
            Image(systemName: cartViewModel.isInWishlist(productId: product.id) ? "heart.fill" : "heart")
                .font(.system(size: 18))
                .foregroundStyle(cartViewModel.isInWishlist(productId: product.id) ? HomeSectorDesign.Colors.saleRed : HomeSectorDesign.Colors.primaryText)
        }
    }

    // MARK: - Add to Cart

    private var addToCartButton: some View {
        VStack(spacing: 0) {
            Divider()
                .overlay(HomeSectorDesign.Colors.border)

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
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text(showAddedFeedback ? "Добавено!" : "Добави в кошницата")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    isAvailable && !isAddingToCart
                        ? HomeSectorDesign.Colors.accent
                        : Color(.systemGray4)
                )
                .foregroundStyle(.white)
                .clipShape(.rect(cornerRadius: 12))
            }
            .disabled(!isAvailable || isAddingToCart)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(HomeSectorDesign.Colors.background)
    }
}
