import SwiftUI
import SwiftData

struct NoConnectionWidget: View {
    @Environment(\.dependencies) private var dependencies
    var connectionManager: ConnectionManager { dependencies.connectionManager }
    @State var isShowingConnectionSheet: Bool = false
    var body: some View {
        VStack {
            Text("No Portiqo Key Detected")
                .font(.title)
            Text("Make sure it's on and nearby")
            Button("Or connect to one") {
                isShowingConnectionSheet = true
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
        .sheet(isPresented: $isShowingConnectionSheet, onDismiss: { connectionManager.stopScan() }) {
            ConnectToKeyView()
        }
    }
}

#Preview("Unknown Card") {
    NoConnectionWidget()
}
