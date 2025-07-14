import Foundation
import SwiftUI
import CoreBluetooth

/// ConnectionManager is responsible for managing the Bluetooth connection between the iOS app
/// and the Portiqo Key device. It handles creating/terminating the connection andd
/// sending/receiving card data,
@Observable
class ConnectionManager: NSObject {
    /// Indicates whether there is a current active connection with the Portiqo Key
    var isKeyConnected: Bool = false

    /// The card's unique identifier.
    var currentCard: UUID? = nil // TODO: Move this up a layer

    private let centralManager = CBCentralManager()

    /// Shows the state of the bluetooth radio (Good, BT off, no permissions, etc.)
    private var btRadioState: CBManagerState = .unknown

    /// Set containing Bluetooth Peripherals that have been discovered while scanning
    private var discoveredPeripherals: Set<CBPeripheral> = []

    /// The Portiqo Key that is currently connected
    private(set) var connectedPeripheral: CBPeripheral?

    /// Portiqo key uses the Nordic UART Service (NUS) to communicate with Portiqo Wallet
    /// (https://docs.nordicsemi.com/bundle/ncs-latest/page/nrf/libraries/bluetooth/services/nus.html)
    ///
    /// Raw command data is written to this characteristic.
    /// This characteristic has UUID 6E400002-B5A3-F393-E0A9-E50E24DCCA9E
    var txCharacteristic: CBCharacteristic?

    /// Raw response data is received from this characteristic.
    /// Portiqo Wallet subscribes to notifications here to receive data.
    /// This characteristic has UUID 6E400003-B5A3-F393-E0A9-E50E24DCCA9E
    var rxCharacteristic: CBCharacteristic?

    /// Starts scanning for Bluetooth devices
    func startScan() async {

    }

    /// Stops scanning for Bluetooth devices
    func stopScan() async {

    }

    /// Establishes a connection to the Portiqo Key
    func connect() async {
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s to simulate HW delay
        self.isKeyConnected = true
    }

    /// Terminates connection to the Portiqo Key
    func disconnect() async {
        try? await Task.sleep(nanoseconds: 200_000_000) // 0.2s to simulate HW delay
        self.isKeyConnected = false
    }

    /// Sends raw data to Portiqo Key
    func send_data() async {

    }
}

extension ConnectionManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        btRadioState = central.state
    }
    
}

extension ConnectionManager: CBPeripheralDelegate {

}


// TODO: Everything below here moves up a layer or two
extension ConnectionManager {
    /// Erases keycard from  Portiqo Key
    func eraseKey() async {
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s to simulate HW delay/
        self.currentCard = nil
    }

    /// Writes a Keycard to the Portiqo Key
    /// - Parameters:
    ///     - card: The keycard to be written
    func sendCard(_ card: Keycard) async {
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s to simulate HW delay/
        self.currentCard = card.id
    }

    /// Reads a physical RF Keycard and creates a Keycard object with its data
    /// - Returns: A Keycard object with the information read from the physical card
    func cloneCard() async -> KeycardAttributes {
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2s delay to simulate user tapping card to Portiqo Key
        return KeycardAttributes(name: "Cloned Card")
    }

    /// Fetches the ID of the Keycard currently stored on the Portiqo Key
    /// - Returns:
    ///     - If a Keycard is currently stored on the Portiqo Key, the ID of that Keycard
    ///     - If no keycard is currently stored on the Portiqo Key, nil.
    func getCurrentCard() async -> UUID? {
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 0.1s to simulate HW delay
        return UUID()
    }
}

private struct ConnectionManagerKey: EnvironmentKey {
    static let defaultValue = ConnectionManager()
}

extension EnvironmentValues {
    /// The current ConnectionManager instance available in the environment.
    var connectionManager: ConnectionManager {
        get { self[ConnectionManagerKey.self] }
        set { self[ConnectionManagerKey.self] = newValue }
    }
}
