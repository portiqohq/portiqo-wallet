import Foundation
import SwiftUI

final class DependencyContainer: ObservableObject {
    let connectionManager: ConnectionManager
    let chameleonCodec: ChameleonCodec
    let chameleon: Chameleon

    init() {
        connectionManager = ConnectionManager()
        chameleonCodec = ChameleonCodec()
        chameleon = Chameleon(codec: chameleonCodec)

        connectionManager.onDataReceived = { [weak self] data in
            self?.chameleonCodec.handleIncomingData(data)
        }

        chameleonCodec.send = { [weak self] data in
            self?.connectionManager.send(data)
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
