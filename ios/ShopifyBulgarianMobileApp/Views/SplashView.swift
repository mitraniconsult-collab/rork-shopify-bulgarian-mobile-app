import SwiftUI

struct SplashView: View {
    @Binding var isActive: Bool
    @State private var opacity = 1.0

    var body: some View {
        ZStack {
            HomeSectorDesign.Colors.background.ignoresSafeArea()

            VStack {
                Image("Logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 160, height: 160)
                    .clipShape(.rect(cornerRadius: 32))
            }
        }
        .opacity(opacity)
        .onAppear {
            Task {
                try? await Task.sleep(for: .seconds(2))
                withAnimation(.easeOut(duration: 0.6)) {
                    opacity = 0
                }
                try? await Task.sleep(for: .seconds(0.6))
                isActive = false
            }
        }
    }
}
