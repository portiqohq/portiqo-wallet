import SwiftUI

/// Icon that displays whether the Portiquo reader is connected
struct ConnectionStatusIcon: View {
    @State var isConnected: Bool
    var body: some View {
        switch isConnected {
        case true:
            Label("Portiqo Key Connected", systemImage: "checkmark.circle.fill")
                .foregroundStyle(Color.green)
        case false:
            Label("Portiqo Key Disconnected", systemImage: "xmark.circle.fill")
                .foregroundStyle(Color.red)
        }
    }
}

#Preview("Connected") {
    ConnectionStatusIcon(isConnected: true)
}

#Preview("Not Connected") {
    ConnectionStatusIcon(isConnected: false)
}
