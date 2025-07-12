import Foundation
import SwiftData

extension WalletSchemaV1 {
    /// Represents a single proximity card
    @Model
    final class Keycard {
        /// The human-readable name given to the card by the user
        var name: String

        init(name: String) {
            self.name = name
        }
    }
}
