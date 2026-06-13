import SwiftUI

struct WishlistView: View {
    @Bindable var cartViewModel: CartViewModel
    @State private var showAddedFeedback = false

    var body: some View {
        Group {
            if cartViewModel.wishlistProducts.isEmpty {
                emptyView
            } else {
                wishlistContent
            }
        }
        .background(HomeSectorDesign.Colors.background)
        .navigationTitle("Любими")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(HomeSectorDesign.Colors.background, for: .navigationBar)
    }

    private var emptyView: some View {
        ContentUnavailableView(
            "Няма любими продукти",
            systemImage: "heart",
            description: Text("Добавете продукти, като натиснете сърцето")
                .foregroundStyle(HomeSectorDesign.Colors.secondaryText)
        )
    }

    private var wishlistContent: some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: HomeSectorDesign.Layout.gridSpacing),
                    GridItem(.flexible(), spacing: HomeSectorDesign.Layout.gridSpacing)
                ],
                spacing: 16
            ) {
                ForEach(cartViewModel.wishlistProducts) { product in
                    WishlistProductCard(
                        product: product,
                        isInWishlist: true,
                        onToggleWishlist: {
                            cartViewModel.toggleWishlist(product: product)
                        },
                        onAddToCart: {
                            Task {
                                if let variant = product.firstVariant {
                                    await cartViewModel.addToCart(variantId: variant.id)
                                    showAddedFeedback.toggle()
                                }
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, HomeSectorDesign.Layout.horizontalPadding)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
    }
}

struct WishlistProductCard: View {
    let product: ShopifyProduct
    let isInWishlist: Bool
    let onToggleWishlist: () -> Void
    let onAddToCart: () -> Void

    private var productPrice: String {
        product.priceRange?.safeMinPrice.formattedAmount ?? ""
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                productImage

                Button {
                    onToggleWishlist()
                } label: {
                    Image(systemName: isInWishlist ? "heart.fill" : "heart")
                        .font(.system(size: 16))
                        .foregroundStyle(isInWishlist ? HomeSectorDesign.Colors.saleRed : HomeSectorDesign.Colors.secondaryText)
                        .padding(10)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(product.title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(HomeSectorDesign.Colors.primaryText)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Text(productPrice)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(HomeSectorDesign.Colors.primaryText)
            }
            .padding(.horizontal, 10)
            .padding(.top, 8)

            Button {
                onAddToCart()
            } label: {
                HStack(spacing: 6) {
                    Text("Добави")
                        .font(.system(size: 14, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(HomeSectorDesign.Colors.accent)
                .foregroundStyle(.white)
                .clipShape(.rect(cornerRadius: 8))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
        }
        .background(HomeSectorDesign.Colors.background)
        .clipShape(.rect(cornerRadius: 12))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }

    private var productImage: some View {
        Color(.systemGray6)
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                if let imageURL = product.firstImage?.imageURL {
                    AsyncImage(url: imageURL) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure:
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundStyle(Color(.systemGray4))
                        default:
                            Rectangle()
                                .fill(Color(.systemGray6))
                        }
                    }
                    .allowsHitTesting(false)
                } else {
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundStyle(Color(.systemGray4))
                }
            }
            .clipShape(.rect(topLeadingRadius: 12, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 12))
    }
}
