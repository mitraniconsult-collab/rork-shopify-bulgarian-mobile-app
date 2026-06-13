import SwiftUI

struct CategoriesView: View {
    @State private var collections: [ShopifyCollection] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @Bindable var cartViewModel: CartViewModel
    @Binding var showHome: Bool

    var body: some View {
        NavigationStack {
            Group {
                if isLoading && collections.isEmpty {
                    skeletonLoading
                } else if let error = errorMessage, collections.isEmpty {
                    errorView(error)
                } else if collections.isEmpty {
                    emptyView
                } else {
                    collectionsList
                }
            }
            .background(HomeSectorDesign.Colors.background)
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
            .task {
                await loadCollections()
            }
            .refreshable {
                collections = []
                await loadCollections()
            }
            .navigationDestination(for: ShopifyCollection.self) { collection in
                CollectionDetailView(handle: collection.handle, title: collection.title, cartViewModel: cartViewModel)
            }
        }
    }

    private var collectionsList: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(collections) { collection in
                    NavigationLink(value: collection) {
                        collectionRow(collection)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, HomeSectorDesign.Layout.horizontalPadding)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
    }

    private func collectionRow(_ collection: ShopifyCollection) -> some View {
        Color(.systemGray5)
            .frame(height: 100)
            .overlay {
                if let imageURL = collection.image?.imageURL {
                    AsyncImage(url: imageURL) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        }
                    }
                    .allowsHitTesting(false)
                }
            }
            .overlay {
                LinearGradient(
                    colors: [.clear, .black.opacity(0.55)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .allowsHitTesting(false)
            }
            .clipShape(.rect(cornerRadius: 12))
            .overlay(alignment: .bottomLeading) {
                Text(collection.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .padding(14)
            }
            .overlay(alignment: .topTrailing) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(14)
            }
    }

    private var skeletonLoading: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(0..<6, id: \.self) { _ in
                    Rectangle()
                        .fill(Color(.systemGray6))
                        .frame(height: 100)
                        .clipShape(.rect(cornerRadius: 12))
                }
            }
            .padding(.horizontal, HomeSectorDesign.Layout.horizontalPadding)
            .padding(.top, 8)
        }
    }

    private var emptyView: some View {
        ContentUnavailableView(
            "Няма колекции",
            systemImage: "rectangle.stack",
            description: Text("Все още няма добавени колекции")
                .foregroundStyle(HomeSectorDesign.Colors.secondaryText)
        )
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
                Task { await loadCollections() }
            }
            .buttonStyle(.borderedProminent)
            .tint(HomeSectorDesign.Colors.accent)
        }
    }

    private func loadCollections() async {
        guard collections.isEmpty else { return }
        isLoading = true
        errorMessage = nil

        do {
            collections = try await ShopifyService.shared.fetchCollections(first: 20)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
