import Foundation
import SwiftUI

/// A centralized container used to manage and inject dependences across the app
///
/// This container contains the following components:
/// - ConnectionManager: Handles low-level bluetooth communication with Portiqo Key
/// - ChameleonCodec: Encodes and decodes messages between Portiqo Key and Portiqo Wallet.
/// - Chameleon: Implementation of specific device operations
final class DependencyContainer: ObservableObject {
    let connectionManager: ConnectionManager
    let chameleonCodec: ChameleonCodec
    let chameleon: Chameleon

    init() {
        connectionManager = ConnectionManager()
        /// This closure handles sending data from ChameleonCodec to ConnectionManager
        /// Encoded data from the codec is piped to ConnectionManager.serialWrite, where it is sent to the Portqio Key.
        let transmitClosure: (Data) -> Void = { [weak connectionManager] data in
            connectionManager?.serialWrite(data)
        }
        chameleonCodec = ChameleonCodec(transmitClosure: transmitClosure)
        chameleon = Chameleon(codec: chameleonCodec)
        /// This closure handles inbound communications from Portiqo Key. When data is received, it is piped to the ChameleonCodec.handleIncomingData method.
        connectionManager.onDataReceived = { [weak self] data in
            self?.chameleonCodec.handleIncomingData(data)
        }
    }
}

private struct DependencyContainerKey: EnvironmentKey {
    static let defaultValue = DependencyContainer()
}

extension EnvironmentValues {
    /// The current ConnectionManager instance available in the environment.
    var dependencies: DependencyContainer {
        get { self[DependencyContainerKey.self] }
        set { self[DependencyContainerKey.self] = newValue }
    }
}
