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

        /// Updates a Keycard's stored properties with the values taken from a KeycardAttributes object
        /// KeycardAttributes objects store temporary values for Keycard properties while the user is editing in CardDetailsView
        func update(from attributes: KeycardAttributes) {
            self.name = attributes.name
        }
    }
}
