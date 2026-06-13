import SwiftUI

struct CollectionDetailView: View {
    let handle: String
    let title: String
    @Bindable var cartViewModel: CartViewModel

    @State private var viewModel: CollectionViewModel

    init(handle: String, title: String, cartViewModel: CartViewModel) {
        self.handle = handle
        self.title = title
        self.cartViewModel = cartViewModel
        self._viewModel = State(initialValue: CollectionViewModel(handle: handle))
    }

    var body: some View {
        ScrollView {
            if viewModel.isLoading && viewModel.products.isEmpty {
                skeletonGrid
            } else if let error = viewModel.errorMessage, viewModel.products.isEmpty {
                errorView(error)
            } else if viewModel.products.isEmpty {
                ContentUnavailableView(
                    "Няма продукти",
                    systemImage: "tray",
                    description: Text("Тази колекция е празна")
                        .foregroundStyle(HomeSectorDesign.Colors.secondaryText)
                )
                .frame(minHeight: 400)
            } else {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: HomeSectorDesign.Layout.gridSpacing),
                        GridItem(.flexible(), spacing: HomeSectorDesign.Layout.gridSpacing)
                    ],
                    spacing: 16
                ) {
                    ForEach(viewModel.products) { product in
                        NavigationLink(value: product) {
                            ProductCardView(product: product, cartViewModel: cartViewModel)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, HomeSectorDesign.Layout.horizontalPadding)
                .padding(.top, 12)
                .padding(.bottom, 32)

                if viewModel.hasNextPage {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .task {
                            await viewModel.loadMoreProducts()
                        }
                }
            }
        }
        .background(HomeSectorDesign.Colors.background)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(HomeSectorDesign.Colors.background, for: .navigationBar)
        .navigationDestination(for: ShopifyProduct.self) { product in
            ProductDetailView(product: product, cartViewModel: cartViewModel)
        }
        .task {
            await viewModel.loadProducts()
        }
    }

    private var skeletonGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: HomeSectorDesign.Layout.gridSpacing),
                GridItem(.flexible(), spacing: HomeSectorDesign.Layout.gridSpacing)
            ],
            spacing: 16
        ) {
            ForEach(0..<6, id: \.self) { _ in
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
                        .frame(height: 14)
                        .frame(width: 80)
                        .clipShape(.rect(cornerRadius: 4))
                }
            }
        }
        .padding(.horizontal, HomeSectorDesign.Layout.horizontalPadding)
        .padding(.top, 12)
    }

    private func errorView(_ message: String) -> some View {
        ContentUnavailableView {
            Label("Грешка", systemImage: "exclamationmark.triangle")
                .foregroundStyle(HomeSectorDesign.Colors.primaryText)
        } description: {
            Text(message)
                .foregroundStyle(HomeSectorDesign.Colors.secondaryText)
        } actions: {
            Button("Опитай отново") {
                Task { await viewModel.loadProducts() }
            }
            .buttonStyle(.borderedProminent)
            .tint(HomeSectorDesign.Colors.accent)
        }
        .frame(minHeight: 400)
    }
}
