import SwiftUI

struct CloneCardView: View {
    @Environment(\.connectionManager) private var connectionManager
    @State var attributes: KeycardAttributes?
    var body: some View {
        VStack {
            if let attributes = attributes {
                CreateNewCardView(attributes: attributes)
            } else {
                Text("Tap Portiqo Key with your Fob")
            }
        }
        .onAppear {
            Task {
                await attributes = connectionManager.cloneCard()
            }
        }
    }
}

#Preview {
    CloneCardView()
}
