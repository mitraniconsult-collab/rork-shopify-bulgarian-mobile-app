import SwiftUI
import ShopifyCheckoutSheetKit

struct CartView: View {
    @Bindable var cartViewModel: CartViewModel
    @Binding var showHome: Bool

    @State private var promoCode: String = ""
    @State private var promoApplied: Bool = false
    @State private var promoError: Bool = false
    @State private var isApplyingPromo: Bool = false

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
        .background(Color(.systemGray6))
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Text("HomeSector")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(HomeSectorDesign.Colors.primaryText)
            }
        }
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(HomeSectorDesign.Colors.background, for: .navigationBar)
    }

    // MARK: - Success

    private var successView: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 120, height: 120)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(Color.green)
            }

            VStack(spacing: 8) {
                Text("Поръчката е успешна!")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(HomeSectorDesign.Colors.primaryText)
                    .multilineTextAlignment(.center)

                Text("Благодарим ви за покупката.\nЩе получите имейл с потвърждение.")
                    .font(.system(size: 15))
                    .foregroundStyle(HomeSectorDesign.Colors.secondaryText)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            Button {
                cartViewModel.showSuccess = false
            } label: {
                Text("Обратно към магазина")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color(hex: "#FF6000"))
                    .foregroundStyle(.white)
                    .clipShape(.rect(cornerRadius: 12))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .padding()
    }

    // MARK: - Empty

    private var emptyCartView: some View {
        VStack(spacing: 20) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color(.systemGray6))
                    .frame(width: 100, height: 100)
                Image(systemName: "bag")
                    .font(.system(size: 44))
                    .foregroundStyle(Color(.systemGray3))
            }

            VStack(spacing: 8) {
                Text("Кошницата е празна")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(HomeSectorDesign.Colors.primaryText)
                Text("Добавете продукти от магазина")
                    .font(.system(size: 15))
                    .foregroundStyle(HomeSectorDesign.Colors.secondaryText)
            }

            Spacer()

            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    showHome = true
                }
            } label: {
                Text("Разгледай продуктите")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color(hex: "#FF6000"))
                    .foregroundStyle(.white)
                    .clipShape(.rect(cornerRadius: 12))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .padding()
        .background(HomeSectorDesign.Colors.background)
    }

    // MARK: - Cart Content

    private var cartContent: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 8) {
                    productsList
                    promoCodeSection
                    orderSummarySection
                }
                .padding(.bottom, 100)
            }

            checkoutSection
        }
    }

    // MARK: - Products List

    private var productsList: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Продукти (\(cartViewModel.cartLines.count))")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(HomeSectorDesign.Colors.secondaryText)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)

            VStack(spacing: 0) {
                ForEach(cartViewModel.cartLines) { line in
                    CartLineItemView(
                        line: line,
                        onUpdateQuantity: { newQuantity in
                            Task {
                                await cartViewModel.updateQuantity(
                                    lineId: line.id,
                                    quantity: newQuantity
                                )
                            }
                        },
                        onRemove: {
                            Task {
                                await cartViewModel.removeFromCart(lineId: line.id)
                            }
                        }
                    )
                    if line.id != cartViewModel.cartLines.last?.id {
                        Divider()
                            .padding(.leading, 108)
                    }
                }
            }
            .background(HomeSectorDesign.Colors.background)
            .clipShape(.rect(cornerRadius: 12))
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Promo Code

    private var promoCodeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Промо код")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(HomeSectorDesign.Colors.secondaryText)
                .padding(.horizontal, 16)
                .padding(.top, 8)

            HStack(spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "tag")
                        .font(.system(size: 15))
                        .foregroundStyle(Color(.systemGray))
                    TextField("Въведи промо код", text: $promoCode)
                        .font(.system(size: 15))
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                }
                .padding(.horizontal, 12)
                .frame(height: 46)
                .background(HomeSectorDesign.Colors.background)
                .clipShape(.rect(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            promoError ? Color.red : (promoApplied ? Color.green : HomeSectorDesign.Colors.border),
                            lineWidth: 1
                        )
                )

                Button {
                    applyPromoCode()
                } label: {
                    if isApplyingPromo {
                        ProgressView()
                            .tint(.white)
                            .frame(width: 70, height: 46)
                    } else {
                        Text(promoApplied ? "Приложен" : "Приложи")
                            .font(.system(size: 14, weight: .semibold))
                            .frame(width: 80, height: 46)
                    }
                }
                .background(promoApplied ? Color.green : Color(hex: "#FF6000"))
                .foregroundStyle(.white)
                .clipShape(.rect(cornerRadius: 10))
                .disabled(promoCode.isEmpty || promoApplied || isApplyingPromo)
            }
            .padding(.horizontal, 16)

            if promoError {
                Text("Невалиден промо код")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.red)
                    .padding(.horizontal, 16)
            }

            if promoApplied {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.green)
                        .font(.system(size: 14))
                    Text("Промо кодът е приложен успешно")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.green)
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.vertical, 4)
        .background(Color(.systemGray6))
    }

    private func applyPromoCode() {
        guard !promoCode.isEmpty else { return }
        isApplyingPromo = true
        promoError = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isApplyingPromo = false
            if promoCode.uppercased() == "HOMESECTOR10" {
                promoApplied = true
            } else {
                promoError = true
            }
        }
    }

    // MARK: - Order Summary

    private var orderSummarySection: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Обобщение на поръчката")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(HomeSectorDesign.Colors.secondaryText)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 10)

            VStack(spacing: 0) {
                summaryRow(
                    icon: "bag",
                    label: "Междинна сума",
                    value: cartViewModel.subtotalAmount,
                    isAccent: false
                )
                Divider().padding(.leading, 16)

                summaryRow(
                    icon: "shippingbox",
                    label: "Доставка",
                    value: "Безплатна",
                    isAccent: false,
                    valueColor: Color.green
                )
                Divider().padding(.leading, 16)

                if promoApplied {
                    summaryRow(
                        icon: "tag",
                        label: "Промо код (\(promoCode))",
                        value: "-10%",
                        isAccent: false,
                        valueColor: Color.red
                    )
                    Divider().padding(.leading, 16)
                }

                summaryRow(
                    icon: "creditcard",
                    label: "Общо",
                    value: cartViewModel.totalAmount,
                    isAccent: true
                )
            }
            .background(HomeSectorDesign.Colors.background)
            .clipShape(.rect(cornerRadius: 12))
            .padding(.horizontal, 16)
        }
    }

    private func summaryRow(
        icon: String,
        label: String,
        value: String,
        isAccent: Bool,
        valueColor: Color? = nil
    ) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(Color(.systemGray))
                .frame(width: 20)
            Text(label)
                .font(.system(size: isAccent ? 16 : 14, weight: isAccent ? .semibold : .regular))
                .foregroundStyle(
                    isAccent
                        ? HomeSectorDesign.Colors.primaryText
                        : HomeSectorDesign.Colors.secondaryText
                )
            Spacer()
            Text(value)
                .font(.system(size: isAccent ? 18 : 14, weight: isAccent ? .bold : .medium))
                .foregroundStyle(
                    valueColor ?? (isAccent ? Color(hex: "#FF6000") : HomeSectorDesign.Colors.primaryText)
                )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    // MARK: - Checkout

    private var checkoutSection: some View {
        VStack(spacing: 10) {
            Divider()

            HStack(spacing: 8) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.green)
                Text("Защитено плащане")
                    .font(.system(size: 12))
                    .foregroundStyle(HomeSectorDesign.Colors.secondaryText)
            }

            Button {
                cartViewModel.prepareCheckout()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "creditcard.fill")
                        .font(.system(size: 16))
                    Text("Завърши поръчката")
                        .font(.system(size: 17, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    cartViewModel.checkoutURL == nil
                        ? Color(.systemGray4)
                        : Color(hex: "#FF6000")
                )
                .foregroundStyle(.white)
                .clipShape(.rect(cornerRadius: 14))
            }
            .disabled(cartViewModel.checkoutURL == nil)
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .background(HomeSectorDesign.Colors.background)
    }
}

// MARK: - Cart Line Item

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
                .frame(width: 88, height: 88)
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
                .clipShape(.rect(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(productTitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(HomeSectorDesign.Colors.primaryText)
                    .lineLimit(2)

                if variantTitle != "Default Title" && !variantTitle.isEmpty {
                    Text(variantTitle)
                        .font(.system(size: 12))
                        .foregroundStyle(HomeSectorDesign.Colors.secondaryText)
                }

                Text(lineTotal)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color(hex: "#FF6000"))

                HStack(spacing: 0) {
                    Button {
                        if quantity > 1 {
                            onUpdateQuantity(quantity - 1)
                        } else {
                            onRemove()
                        }
                    } label: {
                        Image(systemName: quantity > 1 ? "minus" : "trash")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(quantity > 1 ? HomeSectorDesign.Colors.primaryText : Color.red)
                            .frame(width: 32, height: 32)
                            .background(Color(.systemGray6))
                            .clipShape(.rect(cornerRadius: 8))
                    }

                    Text("\(quantity)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(HomeSectorDesign.Colors.primaryText)
                        .frame(width: 36)

                    Button {
                        onUpdateQuantity(quantity + 1)
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(HomeSectorDesign.Colors.primaryText)
                            .frame(width: 32, height: 32)
                            .background(Color(.systemGray6))
                            .clipShape(.rect(cornerRadius: 8))
                    }
                }
                .buttonStyle(.plain)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
