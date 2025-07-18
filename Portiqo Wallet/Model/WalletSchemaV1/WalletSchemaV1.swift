import Foundation
import SwiftData

public enum WalletSchemaV1: VersionedSchema {
    public static var versionIdentifier: Schema.Version {
        .init(1, 0, 0)
    }

    public static var models: [any PersistentModel.Type] {
        [Keycard.self]
    }
}

