import Foundation

 final class ShopifyService: Sendable {
    static let shared = ShopifyService()

    private init() {}

    private func executeQuery<T: Decodable & Sendable>(_ query: String, variables: [String: Any]? = nil) async throws -> T {
        var request = URLRequest(url: ShopifyConfig.storefrontURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(ShopifyConfig.storefrontAccessToken, forHTTPHeaderField: "X-Shopify-Storefront-Access-Token")

        var body: [String: Any] = ["query": query]
        if let variables {
            body["variables"] = variables
        }
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw ShopifyError.networkError
        }

        let graphQLResponse = try JSONDecoder().decode(GraphQLResponse<T>.self, from: data)

        if let errors = graphQLResponse.errors, !errors.isEmpty {
            throw ShopifyError.graphQLError(errors.map { $0.message }.joined(separator: ", "))
        }

        guard let resultData = graphQLResponse.data else {
            throw ShopifyError.noData
        }

        return resultData
    }

    func fetchProducts(first: Int = 20, after: String? = nil) async throws -> Connection<ShopifyProduct> {
        var variables: [String: Any] = ["first": first]
        if let after {
            variables["after"] = after
        }

        let query = """
        query Products($first: Int!, $after: String) {
          products(first: $first, after: $after) {
            edges {
              node {
                id
                title
                description
                handle
                productType
                vendor
                images(first: 5) {
                  edges {
                    node {
                      url
                      altText
                    }
                    cursor
                  }
                  pageInfo { hasNextPage }
                }
                variants(first: 10) {
                  edges {
                    node {
                      id
                      title
                      price { amount currencyCode }
                      availableForSale
                      image { url altText }
                      selectedOptions { name value }
                      compareAtPrice { amount currencyCode }
                    }
                    cursor
                  }
                  pageInfo { hasNextPage }
                }
                priceRange {
                  minVariantPrice { amount currencyCode }
                  maxVariantPrice { amount currencyCode }
                }
              }
              cursor
            }
            pageInfo { hasNextPage hasPreviousPage }
          }
        }
        """

        let result: ProductsData = try await executeQuery(query, variables: variables)
        return result.products
    }

    func fetchCollectionsForHome(first: Int = 20) async throws -> [ShopifyCollection] {
        let query = """
        query CollectionsHome($first: Int!) {
          collections(first: $first) {
            edges {
              node {
                id
                title
                description
                handle
                image { url altText }
                products(first: 1) {
                  edges {
                    node { id }
                  }
                }
              }
              cursor
            }
            pageInfo { hasNextPage }
          }
        }
        """

        let result: CollectionsData = try await executeQuery(query, variables: ["first": first])
        let allCollections = result.collections.edges.map(\.node)
        let filtered = allCollections
            .filter { ($0.products?.edges.count ?? 0) > 0 }
            .prefix(6)
        return Array(filtered)
    }

    func fetchProductsFromCollection(handle: String, first: Int, sortKey: String? = nil) async throws -> Connection<ShopifyProduct> {
        var variables: [String: Any] = ["handle": handle, "first": first]
        if let sortKey {
            variables["sortKey"] = sortKey
        }

        let query = """
        query CollectionProducts($handle: String!, $first: Int!, $sortKey: ProductCollectionSortKeys) {
          collection(handle: $handle) {
            products(first: $first, sortKey: $sortKey) {
              edges {
                node {
                  id
                  title
                  description
                  handle
                  productType
                  vendor
                  images(first: 5) {
                    edges {
                      node { url altText }
                      cursor
                    }
                    pageInfo { hasNextPage }
                  }
                  variants(first: 10) {
                    edges {
                      node {
                        id
                        title
                        price { amount currencyCode }
                        availableForSale
                        image { url altText }
                        selectedOptions { name value }
                        compareAtPrice { amount currencyCode }
                      }
                      cursor
                    }
                    pageInfo { hasNextPage }
                  }
                  priceRange {
                    minVariantPrice { amount currencyCode }
                    maxVariantPrice { amount currencyCode }
                  }
                }
                cursor
              }
              pageInfo { hasNextPage hasPreviousPage }
            }
          }
        }
        """

        let result: CollectionProductsData = try await executeQuery(query, variables: variables)
        guard let products = result.collection?.products else {
            throw ShopifyError.noData
        }
        return products
    }

    func fetchCollections(first: Int = 10) async throws -> [ShopifyCollection] {
        let query = """
        query Collections($first: Int!) {
          collections(first: $first) {
            edges {
              node {
                id
                title
                description
                handle
                image { url altText }
                products(first: 4) {
                  edges {
                    node {
                      id
                      title
                      description
                      handle
                      productType
                      vendor
                      images(first: 1) {
                        edges {
                          node { url altText }
                          cursor
                        }
                        pageInfo { hasNextPage }
                      }
                      variants(first: 1) {
                        edges {
                          node {
                            id
                            title
                            price { amount currencyCode }
                            availableForSale
                            image { url altText }
                            selectedOptions { name value }
                            compareAtPrice { amount currencyCode }
                          }
                          cursor
                        }
                        pageInfo { hasNextPage }
                      }
                      priceRange {
                        minVariantPrice { amount currencyCode }
                        maxVariantPrice { amount currencyCode }
                      }
                    }
                    cursor
                  }
                  pageInfo { hasNextPage }
                }
              }
              cursor
            }
            pageInfo { hasNextPage }
          }
        }
        """

        let result: CollectionsData = try await executeQuery(query, variables: ["first": first])
        return result.collections.edges.map(\.node)
    }

    func fetchCollectionProducts(handle: String, first: Int = 20, after: String? = nil) async throws -> ShopifyCollection? {
        var variables: [String: Any] = ["handle": handle, "first": first]
        if let after {
            variables["after"] = after
        }

        let query = """
        query CollectionByHandle($handle: String!, $first: Int!, $after: String) {
          collection(handle: $handle) {
            id
            title
            description
            handle
            image { url altText }
            products(first: $first, after: $after) {
              edges {
                node {
                  id
                  title
                  description
                  handle
                  productType
                  vendor
                  images(first: 5) {
                    edges {
                      node { url altText }
                      cursor
                    }
                    pageInfo { hasNextPage }
                  }
                  variants(first: 10) {
                    edges {
                      node {
                        id
                        title
                        price { amount currencyCode }
                        availableForSale
                        image { url altText }
                        selectedOptions { name value }
                        compareAtPrice { amount currencyCode }
                      }
                      cursor
                    }
                    pageInfo { hasNextPage }
                  }
                  priceRange {
                    minVariantPrice { amount currencyCode }
                    maxVariantPrice { amount currencyCode }
                  }
                }
                cursor
              }
              pageInfo { hasNextPage hasPreviousPage }
            }
          }
        }
        """

        let result: CollectionByHandleData = try await executeQuery(query, variables: variables)
        return result.collection
    }

    func createCart(variantId: String, quantity: Int = 1) async throws -> ShopifyCart {
        let query = """
        mutation CartCreate($input: CartInput!) {
          cartCreate(input: $input) {
            cart {
              \(cartFragment)
            }
            userErrors { field message }
          }
        }
        """

        let variables: [String: Any] = [
            "input": [
                "lines": [
                    ["merchandiseId": variantId, "quantity": quantity]
                ]
            ]
        ]

        let result: CartCreateData = try await executeQuery(query, variables: variables)
        if let errors = result.cartCreate.userErrors, !errors.isEmpty {
            throw ShopifyError.cartError(errors.map(\.message).joined(separator: ", "))
        }
        guard let cart = result.cartCreate.cart else {
            throw ShopifyError.noData
        }
        return cart
    }

    func addCartLines(cartId: String, variantId: String, quantity: Int = 1) async throws -> ShopifyCart {
        let query = """
        mutation CartLinesAdd($cartId: ID!, $lines: [CartLineInput!]!) {
          cartLinesAdd(cartId: $cartId, lines: $lines) {
            cart {
              \(cartFragment)
            }
            userErrors { field message }
          }
        }
        """

        let variables: [String: Any] = [
            "cartId": cartId,
            "lines": [
                ["merchandiseId": variantId, "quantity": quantity]
            ]
        ]

        let result: CartLinesAddData = try await executeQuery(query, variables: variables)
        if let errors = result.cartLinesAdd.userErrors, !errors.isEmpty {
            throw ShopifyError.cartError(errors.map(\.message).joined(separator: ", "))
        }
        guard let cart = result.cartLinesAdd.cart else {
            throw ShopifyError.noData
        }
        return cart
    }

    func removeCartLines(cartId: String, lineIds: [String]) async throws -> ShopifyCart {
        let query = """
        mutation CartLinesRemove($cartId: ID!, $lineIds: [ID!]!) {
          cartLinesRemove(cartId: $cartId, lineIds: $lineIds) {
            cart {
              \(cartFragment)
            }
            userErrors { field message }
          }
        }
        """

        let variables: [String: Any] = [
            "cartId": cartId,
            "lineIds": lineIds
        ]

        let result: CartLinesRemoveData = try await executeQuery(query, variables: variables)
        if let errors = result.cartLinesRemove.userErrors, !errors.isEmpty {
            throw ShopifyError.cartError(errors.map(\.message).joined(separator: ", "))
        }
        guard let cart = result.cartLinesRemove.cart else {
            throw ShopifyError.noData
        }
        return cart
    }

    func updateCartLines(cartId: String, lineId: String, quantity: Int) async throws -> ShopifyCart {
        let query = """
        mutation CartLinesUpdate($cartId: ID!, $lines: [CartLineUpdateInput!]!) {
          cartLinesUpdate(cartId: $cartId, lines: $lines) {
            cart {
              \(cartFragment)
            }
            userErrors { field message }
          }
        }
        """

        let variables: [String: Any] = [
            "cartId": cartId,
            "lines": [
                ["id": lineId, "quantity": quantity]
            ]
        ]

        let result: CartLinesUpdateData = try await executeQuery(query, variables: variables)
        if let errors = result.cartLinesUpdate.userErrors, !errors.isEmpty {
            throw ShopifyError.cartError(errors.map(\.message).joined(separator: ", "))
        }
        guard let cart = result.cartLinesUpdate.cart else {
            throw ShopifyError.noData
        }
        return cart
    }

    func fetchCart(cartId: String) async throws -> ShopifyCart? {
        let query = """
        query Cart($cartId: ID!) {
          cart(id: $cartId) {
            \(cartFragment)
          }
        }
        """

        let result: CartFetchData = try await executeQuery(query, variables: ["cartId": cartId])
        return result.cart
    }

    func fetchProductByHandle(handle: String) async throws -> ShopifyProduct? {
        let query = """
        query ProductByHandle($handle: String!) {
          product(handle: $handle) {
            id
            title
            description
            handle
            productType
            vendor
            images(first: 10) {
              edges {
                node { url altText }
                cursor
              }
              pageInfo { hasNextPage }
            }
            variants(first: 20) {
              edges {
                node {
                  id
                  title
                  price { amount currencyCode }
                  availableForSale
                  image { url altText }
                  selectedOptions { name value }
                  compareAtPrice { amount currencyCode }
                }
                cursor
              }
              pageInfo { hasNextPage }
            }
            priceRange {
              minVariantPrice { amount currencyCode }
              maxVariantPrice { amount currencyCode }
            }
          }
        }
        """

        let result: ProductByHandleData = try await executeQuery(query, variables: ["handle": handle])
        return result.product
    }

    func predictiveSearch(query: String, limit: Int = 10) async throws -> [PredictiveSearchProduct] {
        let variables: [String: Any] = ["query": query, "limit": limit]

        let gql = """
        query PredictiveSearch($query: String!, $limit: Int!) {
          predictiveSearch(query: $query, limit: $limit, types: PRODUCT) {
            products {
              id
              title
              handle
              vendor
              images(first: 1) {
                edges {
                  node { url altText }
                  cursor
                }
                pageInfo { hasNextPage }
              }
              variants(first: 1) {
                edges {
                  node {
                    id
                    title
                    price { amount currencyCode }
                    availableForSale
                    image { url altText }
                    selectedOptions { name value }
                    compareAtPrice { amount currencyCode }
                  }
                  cursor
                }
                pageInfo { hasNextPage }
              }
              priceRange {
                minVariantPrice { amount currencyCode }
                maxVariantPrice { amount currencyCode }
              }
            }
          }
        }
        """

        let result: PredictiveSearchData = try await executeQuery(gql, variables: variables)
        return result.predictiveSearch?.products ?? []
    }

    private var cartFragment: String {
        """
        id
        checkoutUrl
        lines(first: 50) {
          edges {
            node {
              id
              quantity
              merchandise {
                ... on ProductVariant {
                  id
                  title
                  product { title handle }
                  image { url altText }
                  price { amount currencyCode }
                }
              }
              cost {
                totalAmount { amount currencyCode }
              }
            }
            cursor
          }
          pageInfo { hasNextPage }
        }
        cost {
          totalAmount { amount currencyCode }
          subtotalAmount { amount currencyCode }
          totalTaxAmount { amount currencyCode }
        }
        """
    }
}

 enum ShopifyError: Error, LocalizedError, Sendable {
    case networkError
    case graphQLError(String)
    case noData
    case cartError(String)

    var errorDescription: String? {
        switch self {
        case .networkError:
            return "Грешка в мрежата. Моля, опитайте отново."
        case .graphQLError(let message):
            return "Грешка: \(message)"
        case .noData:
            return "Няма данни от сървъра."
        case .cartError(let message):
            return "Грешка в кошницата: \(message)"
        }
    }
}
