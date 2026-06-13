import SwiftUI
import ShopifyCheckoutSheetKit

struct CartView: View {
    @Bindable var cartViewModel: CartViewModel
    @Binding var showHome: Bool

    var body: some View {
        Group {
            if cartViewModel.showSuccess {
                successView
            } else if cartViewModel.cartLines.isEmpty {
                emptyCartView
            } else {
                cartContent
            }
        }
        .background(HomeSectorDesign.Colors.background)
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        showHome = true
                    }
                } label: {
                    Text("HomeSector")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(HomeSectorDesign.Colors.primaryText)
                }
            }
        }
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(HomeSectorDesign.Colors.background, for: .navigationBar)
    }

    // MARK: - Success

    private var successView: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(Color.green)

            Text("Поръчката е успешна!")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(HomeSectorDesign.Colors.primaryText)
                .multilineTextAlignment(.center)

            Text("Благодарим ви за покупката.")
                .font(.system(size: 15))
                .foregroundStyle(HomeSectorDesign.Colors.secondaryText)
                .multilineTextAlignment(.center)

            Button {
                cartViewModel.showSuccess = false
            } label: {
                Text("Обратно към магазина")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(HomeSectorDesign.Colors.accent)
                    .foregroundStyle(.white)
                    .clipShape(.rect(cornerRadius: 12))
            }
            .padding(.horizontal, 32)
        }
        .padding()
    }

    // MARK: - Empty

    private var emptyCartView: some View {
        ContentUnavailableView(
            "Кошницата е празна",
            systemImage: "bag",
            description: Text("Добавете продукти от магазина")
                .foregroundStyle(HomeSectorDesign.Colors.secondaryText)
        )
    }

    // MARK: - Cart Content

    private var cartContent: some View {
        VStack(spacing: 0) {
            List {
                ForEach(cartViewModel.cartLines) { line in
                    CartLineItemView(
                        line: line,
                        onUpdateQuantity: { newQuantity in
                            Task {
                                await cartViewModel.updateQuantity(lineId: line.id, quantity: newQuantity)
                            }
                        },
                        onRemove: {
                            Task {
                                await cartViewModel.removeFromCart(lineId: line.id)
                            }
                        }
                    )
                    .listRowBackground(HomeSectorDesign.Colors.background)
                    .listRowSeparatorTint(HomeSectorDesign.Colors.border)
                }
            }
            .listStyle(.plain)
            .background(HomeSectorDesign.Colors.background)

            checkoutSection
        }
    }

    // MARK: - Checkout

    private var checkoutSection: some View {
        VStack(spacing: 12) {
            Divider()
                .overlay(HomeSectorDesign.Colors.border)

            VStack(spacing: 8) {
                HStack {
                    Text("Междинна сума")
                        .font(.system(size: 15))
                        .foregroundStyle(HomeSectorDesign.Colors.secondaryText)
                    Spacer()
                    Text(cartViewModel.subtotalAmount)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(HomeSectorDesign.Colors.primaryText)
                }

                HStack {
                    Text("Общо")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(HomeSectorDesign.Colors.primaryText)
                    Spacer()
                    Text(cartViewModel.totalAmount)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(HomeSectorDesign.Colors.primaryText)
                }
            }
            .padding(.horizontal, 16)

            Button {
                cartViewModel.prepareCheckout()
            } label: {
                Text("Плати с карта")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(HomeSectorDesign.Colors.accent)
                    .foregroundStyle(.white)
                    .clipShape(.rect(cornerRadius: 12))
            }
            .disabled(cartViewModel.checkoutURL == nil)
            .opacity(cartViewModel.checkoutURL == nil ? 0.4 : 1)
            .padding(.horizontal, 16)

            Text("Защитено плащане в приложението")
                .font(.system(size: 12))
                .foregroundStyle(HomeSectorDesign.Colors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
        }
        .padding(.vertical, 12)
        .background(HomeSectorDesign.Colors.background)
    }
}

struct CartLineItemView: View {
    let line: CartLine
    let onUpdateQuantity: (Int) -> Void
    let onRemove: () -> Void

    private var productTitle: String {
        line.merchandise?.product?.title ?? "Продукт"
    }

    private var variantTitle: String {
        line.merchandise?.title ?? ""
    }

    private var lineTotal: String {
        line.cost?.safeTotal.formattedAmount ?? "0.00 лв."
    }

    private var quantity: Int {
        line.safeQuantity
    }

    private var imageURL: URL? {
        line.merchandise?.image?.imageURL
    }

    var body: some View {
        HStack(spacing: 12) {
            Color(.systemGray6)
                .frame(width: 80, height: 80)
                .overlay {
                    if let url = imageURL {
                        AsyncImage(url: url) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
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
                Text(productTitle)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(HomeSectorDesign.Colors.primaryText)
                    .lineLimit(2)

                if variantTitle != "Default Title" && !variantTitle.isEmpty {
                    Text(variantTitle)
                        .font(.system(size: 13))
                        .foregroundStyle(HomeSectorDesign.Colors.secondaryText)
                }

                Text(lineTotal)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(HomeSectorDesign.Colors.primaryText)

                HStack(spacing: 12) {
                    Button {
                        if quantity > 1 {
                            onUpdateQuantity(quantity - 1)
                        } else {
                            onRemove()
                        }
                    } label: {
                        Image(systemName: quantity > 1 ? "minus.circle" : "trash.circle")
                            .font(.system(size: 22))
                            .foregroundStyle(quantity > 1 ? HomeSectorDesign.Colors.primaryText : HomeSectorDesign.Colors.saleRed)
                    }

                    Text("\(quantity)")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(HomeSectorDesign.Colors.primaryText)
                        .frame(minWidth: 24)

                    Button {
                        onUpdateQuantity(quantity + 1)
                    } label: {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 22))
                            .foregroundStyle(HomeSectorDesign.Colors.primaryText)
                    }
                }
                .buttonStyle(.plain)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}
