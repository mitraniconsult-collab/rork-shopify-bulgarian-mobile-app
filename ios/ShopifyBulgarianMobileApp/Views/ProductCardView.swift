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

    private var discountPercent: Int? {
        guard let compareAt = compareAtPrice,
              let compareValue = Double(compareAt.safeAmount),
              let currentValue = Double(product.priceRange?.safeMinPrice.safeAmount ?? "0"),
              compareValue > currentValue else { return nil }
        return Int(((compareValue - currentValue) / compareValue) * 100)
    }

    private var isNew: Bool {
    return false
}

    private var mockRating: Double {
        let hash = abs(product.id.hashValue)
        let ratings = [4.2, 4.5, 4.7, 4.8, 4.3, 4.6, 4.9, 4.4]
        return ratings[hash % ratings.count]
    }

    private var mockReviewCount: Int {
        let hash = abs(product.id.hashValue)
        return (hash % 200) + 10
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            imageSection
            infoSection
        }
        .background(Color.white)
        .clipShape(.rect(cornerRadius: 14))
        .shadow(color: .black.opacity(0.07), radius: 10, x: 0, y: 3)
    }

    // MARK: - Image

    private var imageSection: some View {
        ZStack(alignment: .top) {
            productImage

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    if let pct = discountPercent {
                        badgeView("-\(pct)%", color: Color.red)
                    } else if  {
                        badgeView("НОВО", color: Color(hex: "#FF6000"))
                    }
                }

                Spacer()

                if let vm = cartViewModel {
                    Button {
                        vm.toggleWishlist(product: product)
                    } label: {
                        Image(
                            systemName: vm.isInWishlist(productId: product.id)
                                ? "heart.fill"
                                : "heart"
                        )
                        .font(.system(size: 15))
                        .foregroundStyle(
                            vm.isInWishlist(productId: product.id)
                                ? Color.red
                                : Color(.systemGray)
                        )
                        .frame(width: 32, height: 32)
                        .background(Color.white.opacity(0.92))
                        .clipShape(.circle)
                        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(8)
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
                            Color(.systemGray6)
                        }
                    }
                    .allowsHitTesting(false)
                } else {
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundStyle(Color(.systemGray4))
                }
            }
            .clipShape(
                .rect(
                    topLeadingRadius: 14,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 14
                )
            )
    }

    private func badgeView(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 7)
            .padding(.vertical, 4)
            .background(color)
            .clipShape(.rect(cornerRadius: 6))
    }

    // MARK: - Info

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(product.title)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            ratingRow

            priceRow
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
    }

    private var ratingRow: some View {
        HStack(spacing: 4) {
            HStack(spacing: 2) {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: starIcon(for: star, rating: mockRating))
                        .font(.system(size: 10))
                        .foregroundStyle(Color(hex: "#FFB800"))
                }
            }
            Text(String(format: "%.1f", mockRating))
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color(.systemGray))
            Text("(\(mockReviewCount))")
                .font(.system(size: 11))
                .foregroundStyle(Color(.systemGray2))
        }
    }

    private func starIcon(for position: Int, rating: Double) -> String {
        if Double(position) <= rating {
            return "star.fill"
        } else if Double(position) - 0.5 <= rating {
            return "star.leadinghalf.filled"
        } else {
            return "star"
        }
    }

    private var priceRow: some View {
        HStack(spacing: 6) {
            if hasSale, let compareAt = compareAtPrice {
                Text(productPrice)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color.red)
                Text(compareAt.formattedAmount)
                    .font(.system(size: 12))
                    .foregroundStyle(Color(.systemGray))
                    .strikethrough()
            } else {
                Text(productPrice)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color(hex: "#FF6000"))
            }
            Spacer()
        }
    }
}
