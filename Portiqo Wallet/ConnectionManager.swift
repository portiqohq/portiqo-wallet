import Foundation
import SwiftUI
import CoreBluetooth

/// ConnectionManager is responsible for managing the Bluetooth connection between the iOS app
/// and the Portiqo Key device. It handles creating/terminating the connection
/// and sending/receiving raw data to Portiqo Key.
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
    private(set) var discoveredPeripherals: Set<CBPeripheral> = []

    /// The Portiqo Key that is currently connected
    private(set) var connectedPeripheral: CBPeripheral?

    /// Stores the Peripheral the user has chosen to connect to. Used to reject notifications that may arise from unrelated devices.
    private var pendingConnectionTo: CBPeripheral?

    /// Portiqo key uses the Nordic UART Service (NUS) to communicate with Portiqo Wallet
    /// (https://docs.nordicsemi.com/bundle/ncs-latest/page/nrf/libraries/bluetooth/services/nus.html)
    ///
    /// UUID that is advertised by devices that use NUS. This is used to filter out random "noise" devices when scanning and
    /// to identify the NUS service once connected.
    private let nusServiceUUID = CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
    /// Raw command data is written to this characteristic.
    /// This characteristic has UUID 6E400002-B5A3-F393-E0A9-E50E24DCCA9E
    var txCharacteristic: CBCharacteristic?
    /// Raw response data is received from this characteristic.
    /// Portiqo Wallet subscribes to notifications here to receive data.
    /// This characteristic has UUID 6E400003-B5A3-F393-E0A9-E50E24DCCA9E
    var rxCharacteristic: CBCharacteristic?
    ///
    /// The following UUIDs are used to identify the tx and rx characteristics:
    private let nusTxUUID = CBUUID(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E") // Write
    private let nusRxUUID = CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")


    override init() {
        super.init()
        self.centralManager.delegate = self // 2
    }

    /// Starts scanning for Bluetooth devices
    func startScan() {
        guard btRadioState == .poweredOn else {
            // TODO: Add error handling here
            print("Couldn't start scan because radio wasn't ready")
            return
        }
        centralManager.scanForPeripherals(withServices: [nusServiceUUID], options: nil)
    }

    /// Stops scanning for Bluetooth devices
    func stopScan() {
        centralManager.stopScan()
        discoveredPeripherals.removeAll()
    }

    /// Establishes a connection to the Portiqo Key
    func connect(to peripheral: CBPeripheral) {
        guard btRadioState == .poweredOn else {
            // TODO: Add error handling
            print("Tried to connect with BT off")
            return
        }
        self.pendingConnectionTo = peripheral
        centralManager.connect(peripheral, options: nil)
        stopScan()
    }

    /// Terminates connection to the Portiqo Key
    func disconnect() async {
        try? await Task.sleep(nanoseconds: 200_000_000) // 0.2s to simulate HW delay
    }

    /// Sends raw data to Portiqo Key
    func send_data() async {

    }
}


extension ConnectionManager: CBCentralManagerDelegate {
    /// Updates btRadioState when the radio's status changes (airplane mode turned on, for example)
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        btRadioState = central.state
    }

    /// When a Bluetooth peripheral is discovered, add it discoveredPeripherals
    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String : Any],
        rssi RSSI: NSNumber
    ) {
        if !discoveredPeripherals.contains(peripheral) {
            discoveredPeripherals.insert(peripheral)
        }
    }

    // When a device connects, discover services and set it as the connectedPeripheral
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(peripheral.name ?? "device")")
        guard peripheral == self.pendingConnectionTo else { return } // Reject advances from random peripherals
        peripheral.delegate = self
        peripheral.discoverServices([nusServiceUUID])
        self.connectedPeripheral = peripheral
    }

}

extension ConnectionManager: CBPeripheralDelegate {
    /// When a service is discovered, discover its characteristics
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else {
            print("Service discovery failed: \(error!.localizedDescription)")
            return
        }
        guard let services = peripheral.services else { return }

        for service in services {
            print("Discovered service: \(service.uuid)")
            peripheral.discoverCharacteristics([nusTxUUID, nusRxUUID], for: service)
        }
    }

    /// When a NUS characteristics are discovered, save and enable them
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }

        for characteristic in characteristics {
            print("Discovered characteristic: \(characteristic.uuid)")

            if characteristic.uuid == nusTxUUID {
                self.txCharacteristic = characteristic
            } else if characteristic.uuid == nusRxUUID {
                self.rxCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
        if txCharacteristic != nil && rxCharacteristic != nil {
            print("Ready to send/receive data")
            self.isKeyConnected = true
        }
    }
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
