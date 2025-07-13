import Foundation
import SwiftUI

/// ConnectionManager is responsible for managing the Bluetooth connection between the iOS app
/// and the Portiqo Key device. It handles creating/terminating the connection andd
/// sending/receiving card data,
@Observable
class ConnectionManager {
    /// Indicates whether there is a current active connection with the Portiqo Key
    var isKeyConnected: Bool = false
    /// The card's unique identifier.
    var currentCard: UUID? = nil

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
    func cloneCard() async -> Keycard? {
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2s delay to simulate user tapping card to Portiqo Key
        return Keycard(name: "Cloned Card")
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
