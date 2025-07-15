import Foundation
import CoreBluetooth

enum ConnectionError: Error, LocalizedError, Equatable {
    case bluetoothOff // Bluetooth is turned off. Airplane mode?
    case bluetoothMissingPermissions // User hasn't granted required permissions for the app to use Bluetooth
    case bluetoothRadioNotAvailable // BT radio not available, for some other reason. Simulator?

    case peripheralNotFound
    case connectionFailed(CBPeripheral)
    case serviceDiscoveryFailed(CBPeripheral)
    case characteristicDiscoveryFailed(CBService)
    case writeFailed
    case readTimeout
    case unknown

    var errorDescription: String? {
        switch self {
        case .bluetoothOff:
            return "Bluetooth is turned off"
        case .bluetoothMissingPermissions:
            return "Bluetooth permissions are missing."
        case .bluetoothRadioNotAvailable:
            return "Bluetooth radio not available for some reason. Simulator?"

        case .peripheralNotFound:
            return "Device not found."
        case .connectionFailed(let p):
            return "Failed to connect to \(p.name ?? "device")."
        case .serviceDiscoveryFailed(let p):
            return "Could not discover services on \(p.name ?? "device")."
        case .characteristicDiscoveryFailed(let s):
            return "Could not discover characteristics for service \(s.uuid)."
        case .writeFailed:
            return "Failed to send data."
        case .readTimeout:
            return "Device did not respond in time."
        case .unknown:
            return "An unknown error occurred."
        }
    }
}
