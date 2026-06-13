import SwiftUI

@Observable
final class CartViewModel {
    var cart: ShopifyCart?
    var isLoading: Bool = false
    var errorMessage: String?
    var showCheckoutSheet: Bool = false
    var showSuccess: Bool = false

    var cartLines: [CartLine] {
        cart?.safeLines ?? []
    }

    var totalAmount: String {
        cart?.cost?.safeTotal.formattedAmount ?? "0.00 лв."
    }

    var subtotalAmount: String {
        cart?.cost?.safeSubtotal.formattedAmount ?? "0.00 лв."
    }

    var itemCount: Int {
        cart?.totalQuantity ?? 0
    }

    var checkoutURL: URL? {
        guard let urlString = cart?.checkoutUrl else { return nil }
        return URL(string: urlString)
    }

    var wishlistProducts: [ShopifyProduct] = []

    func isInWishlist(productId: String) -> Bool {
        wishlistProducts.contains(where: { $0.id == productId })
    }

    func toggleWishlist(product: ShopifyProduct) {
        if let index = wishlistProducts.firstIndex(where: { $0.id == product.id }) {
            wishlistProducts.remove(at: index)
        } else {
            wishlistProducts.append(product)
        }
    }

    func clearCart() {
        cart = nil
    }

    func addToCart(variantId: String, quantity: Int = 1) async {
        isLoading = true
        errorMessage = nil

        do {
            if let existingCart = cart {
                cart = try await ShopifyService.shared.addCartLines(
                    cartId: existingCart.id,
                    variantId: variantId,
                    quantity: quantity
                )
            } else {
                cart = try await ShopifyService.shared.createCart(
                    variantId: variantId,
                    quantity: quantity
                )
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func removeFromCart(lineId: String) async {
        guard let cartId = cart?.id else { return }
        isLoading = true
        errorMessage = nil

        do {
            cart = try await ShopifyService.shared.removeCartLines(
                cartId: cartId,
                lineIds: [lineId]
            )
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func updateQuantity(lineId: String, quantity: Int) async {
        guard let cartId = cart?.id else { return }
        isLoading = true
        errorMessage = nil

        do {
            if quantity <= 0 {
                cart = try await ShopifyService.shared.removeCartLines(
                    cartId: cartId,
                    lineIds: [lineId]
                )
            } else {
                cart = try await ShopifyService.shared.updateCartLines(
                    cartId: cartId,
                    lineId: lineId,
                    quantity: quantity
                )
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func prepareCheckout() {
        guard checkoutURL != nil else {
            errorMessage = "Няма активна кошница за плащане."
            return
        }
        showCheckoutSheet = true
    }

    func handleCheckoutComplete() {
        showCheckoutSheet = false
        clearCart()
        showSuccess = true
    }

    func handleCheckoutCancel() {
        showCheckoutSheet = false
    }

    func handleCheckoutFail(error: Error) {
        showCheckoutSheet = false
        errorMessage = "Грешка при плащане: \(error.localizedDescription)"
    }
}
