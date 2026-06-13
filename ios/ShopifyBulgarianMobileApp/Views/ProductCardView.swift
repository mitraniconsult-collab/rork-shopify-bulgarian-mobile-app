import SwiftUI

struct ProductCardView: View {
    let product: ShopifyProduct
    var cartViewModel: CartViewModel? = nil

    private var productPrice: String {
        product.priceRange?.safeMinPrice.formattedAmount ?? ""
    }

    private var compareAtPrice: MoneyV2? {
        product.firstVariant?.safeCompareAtPrice
    }

    private var hasSale: Bool {
        guard let compareAt = compareAtPrice,
              let compareValue = Double(compareAt.safeAmount),
              let currentValue = Double(product.priceRange?.safeMinPrice.safeAmount ?? "0") else { return false }
        return compareValue > currentValue
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                productImage

                if let vm = cartViewModel {
                    Button {
                        vm.toggleWishlist(product: product)
                    } label: {
                        Image(systemName: vm.isInWishlist(productId: product.id) ? "heart.fill" : "heart")
                            .font(.system(size: 16))
                            .foregroundStyle(vm.isInWishlist(productId: product.id) ? HomeSectorDesign.Colors.saleRed : HomeSectorDesign.Colors.secondaryText)
                            .padding(10)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(product.title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(HomeSectorDesign.Colors.primaryText)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                priceRow
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 10)
            .padding(.top, 8)
        }
        .background(HomeSectorDesign.Colors.background)
        .clipShape(.rect(cornerRadius: 12))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(HomeSectorDesign.Colors.border)
                .frame(height: 1)
        }
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

    private var priceRow: some View {
        HStack(spacing: 4) {
            if hasSale, let compareAt = compareAtPrice {
                Text(productPrice)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(HomeSectorDesign.Colors.saleRed)
                Text(compareAt.formattedAmount)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(HomeSectorDesign.Colors.struckGray)
                    .strikethrough()
            } else {
                Text(productPrice)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(HomeSectorDesign.Colors.primaryText)
            }
        }
    }
}
