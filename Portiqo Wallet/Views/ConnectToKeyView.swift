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
                    Button(peripheral.name ?? "Unknown Device") {
                        connect(to: peripheral)
                    }
                }
            }
        }
        .onAppear {
            connectionManager.startScan()
        }
    }

    func connect(to peripheral: CBPeripheral) {
        connectionManager.connect(to: peripheral)
    }
}

#Preview {
    ConnectToKeyView()
}
