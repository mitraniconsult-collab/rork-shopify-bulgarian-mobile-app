import SwiftUI

struct CollectionCardView: View {
    let collection: ShopifyCollection

    var body: some View {
        Color(.systemGray5)
            .frame(width: 160, height: 100)
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
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .padding(10)
            }
    }
}
