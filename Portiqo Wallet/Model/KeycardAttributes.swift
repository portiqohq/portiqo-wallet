import Foundation

/// A container that duplicates a Keycard's user-facing attributes
/// Used to allow editing in CardDetailsView without mutating the actual object in Swiftdata until save
@Observable
class KeycardAttributes {
    var name: String
    init(keycard: Keycard) {
        self.name = keycard.name
    }
}
