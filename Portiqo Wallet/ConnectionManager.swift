import Foundation

/// ConnectionManager is responsible for managing the Bluetooth connection between the iOS app
/// and the Portiqo Key device. It handles creating/terminating the connection andd
/// sending/receiving card data,
class ConnectionManager {
    /// Indicates whether there is a current active connection with the Portiqo Key
    var isKeyConnected: Bool = false
    /// The card's unique identifier.
    var currentCard: UUID? = nil

    /// Establishes a connection to the Portiqo Key
    func connect() {
        self.isKeyConnected = true
    }

    /// Terminates connection to the Portiqo Key
    func disconnect() {
        self.isKeyConnected = false
    }

    /// Writes a Keycard to the Portiqo Key
    /// - Parameters:
    ///     - card: The keycard to be written
    func sendCard(_ card: Keycard) {}

    /// Reads a physical RF Keycard and creates a Keycard object with its data
    /// - Returns: A Keycard object with the information read from the physical card
    func cloneCard() -> Keycard? { return nil }

    /// Fetches the ID of the Keycard currently stored on the Portiqo Key
    /// - Returns:
    ///     - If a Keycard is currently stored on the Portiqo Key, the ID of that Keycard
    ///     - If no keycard is currently stored on the Portiqo Key, nil.
    func getCurrentCard() -> UUID? { return nil }

}
