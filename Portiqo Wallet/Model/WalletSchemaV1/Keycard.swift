import Foundation
import SwiftData

extension WalletSchemaV1 {
    /// Represents a single proximity card
    @Model
    final class Keycard {
        /// A unique ID that identifies the card
        @Attribute(.unique) var id: UUID
        /// The human-readable name given to the card by the user
        var name: String

        init(name: String) {
            self.name = name
            self.id = UUID()
        }
    }
}
