import Foundation
import SwiftUI

final class DependencyContainer: ObservableObject {
    let chameleonCodec: ChameleonCodec
    let connectionManager: ConnectionManager

    init() {
        chameleonCodec = ChameleonCodec()
        connectionManager = ConnectionManager()

        connectionManager.onDataReceived = { [weak chameleonCodec] data in
            chameleonCodec?.handleIncomingData(data)
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
