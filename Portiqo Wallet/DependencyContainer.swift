import Foundation
import SwiftUI

final class DependencyContainer: ObservableObject {
    let connectionManager: ConnectionManager
    let chameleonCodec: ChameleonCodec
    let chameleon: Chameleon

    init() {
        connectionManager = ConnectionManager()
        let sendClosure: (Data) -> Void = { [weak connectionManager] data in
            connectionManager?.send(data)
        }
        chameleonCodec = ChameleonCodec(send: sendClosure)
        chameleon = Chameleon(codec: chameleonCodec)

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
