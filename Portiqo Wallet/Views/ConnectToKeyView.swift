import SwiftUI
import CoreBluetooth

struct ConnectToKeyView: View {
    @Environment(\.connectionManager) private var connectionManager
    var detectedPeripherals: [CBPeripheral] { connectionManager.discoveredPeripherals.sorted { $0.name ?? "" < $1.name ?? "" } }
    var body: some View {
        VStack {
            Text("Select your Portiqo Key")
            List {
                ForEach(detectedPeripherals, id: \.identifier) { peripheral in
                    Text(peripheral.name ?? "Unknown peripheral")
                }
            }
        }
        .onAppear {
            connectionManager.startScan()
        }
    }
}

#Preview {
    ConnectToKeyView()
}
