import SwiftUI

struct ProfileView: View {
    @Bindable var cartViewModel: CartViewModel
    @Binding var showHome: Bool

    var body: some View {
        NavigationStack {
            List {
                // Store info
                Section {
                    HStack(spacing: 14) {
                        Image(systemName: "storefront")
                            .font(.system(size: 28))
                            .foregroundStyle(HomeSectorDesign.Colors.primaryText)
                            .frame(width: 56, height: 56)
                            .background(HomeSectorDesign.Colors.inputBackground)
                            .clipShape(.rect(cornerRadius: 14))

                        VStack(alignment: .leading, spacing: 3) {
                            Text("HomeSector")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(HomeSectorDesign.Colors.primaryText)

                            Text("homesectorr.myshopify.com")
                                .font(.system(size: 13))
                                .foregroundStyle(HomeSectorDesign.Colors.secondaryText)
                        }
                    }
                    .padding(.vertical, 6)
                }

                // Favorites
                Section {
                    NavigationLink {
                        WishlistView(cartViewModel: cartViewModel)
                    } label: {
                        Label {
                            Text("Любими")
                                .font(.system(size: 15))
                                .foregroundStyle(HomeSectorDesign.Colors.primaryText)
                        } icon: {
                            Image(systemName: "heart.fill")
                                .foregroundStyle(HomeSectorDesign.Colors.saleRed)
                        }

                        Spacer()

                        if cartViewModel.wishlistProducts.count > 0 {
                            Text("\(cartViewModel.wishlistProducts.count)")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(HomeSectorDesign.Colors.secondaryText)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(HomeSectorDesign.Colors.inputBackground)
                                .clipShape(.rect(cornerRadius: 8))
                        }
                    }
                }

                // Store info
                Section {
                    Label {
                        Text("Български магазин")
                            .font(.system(size: 15))
                            .foregroundStyle(HomeSectorDesign.Colors.primaryText)
                    } icon: {
                        Image(systemName: "flag.fill")
                            .foregroundStyle(HomeSectorDesign.Colors.primaryText)
                    }
                    Label {
                        Text("Плащане с карта")
                            .font(.system(size: 15))
                            .foregroundStyle(HomeSectorDesign.Colors.primaryText)
                    } icon: {
                        Image(systemName: "creditcard.fill")
                            .foregroundStyle(HomeSectorDesign.Colors.primaryText)
                    }
                    Label {
                        Text("Бърза доставка")
                            .font(.system(size: 15))
                            .foregroundStyle(HomeSectorDesign.Colors.primaryText)
                    } icon: {
                        Image(systemName: "shippingbox.fill")
                            .foregroundStyle(HomeSectorDesign.Colors.primaryText)
                    }
                } header: {
                    Text("Информация")
                        .font(.system(size: 13))
                        .foregroundStyle(HomeSectorDesign.Colors.secondaryText)
                }

                // Contacts
                Section {
                    Link(destination: URL(string: "mailto:support@homesectorr.myshopify.com")!) {
                        Label {
                            Text("Имейл")
                                .font(.system(size: 15))
                                .foregroundStyle(HomeSectorDesign.Colors.primaryText)
                        } icon: {
                            Image(systemName: "envelope.fill")
                                .foregroundStyle(HomeSectorDesign.Colors.primaryText)
                        }
                    }

                    Link(destination: URL(string: "https://homesectorr.myshopify.com")!) {
                        Label {
                            Text("Уебсайт")
                                .font(.system(size: 15))
                                .foregroundStyle(HomeSectorDesign.Colors.primaryText)
                        } icon: {
                            Image(systemName: "globe")
                                .foregroundStyle(HomeSectorDesign.Colors.primaryText)
                        }
                    }
                } header: {
                    Text("Контакти")
                        .font(.system(size: 13))
                        .foregroundStyle(HomeSectorDesign.Colors.secondaryText)
                }

                // Legal
                Section {
                    Label {
                        Text("Условия за ползване")
                            .font(.system(size: 15))
                            .foregroundStyle(HomeSectorDesign.Colors.primaryText)
                    } icon: {
                        Image(systemName: "doc.text.fill")
                            .foregroundStyle(HomeSectorDesign.Colors.primaryText)
                    }
                    Label {
                        Text("Политика за поверителност")
                            .font(.system(size: 15))
                            .foregroundStyle(HomeSectorDesign.Colors.primaryText)
                    } icon: {
                        Image(systemName: "lock.shield.fill")
                            .foregroundStyle(HomeSectorDesign.Colors.primaryText)
                    }
                } header: {
                    Text("Правна информация")
                        .font(.system(size: 13))
                        .foregroundStyle(HomeSectorDesign.Colors.secondaryText)
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
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
        }
    }
}
