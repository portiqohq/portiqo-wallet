import Foundation

/// A wrapper for messages encoded/decoded from Portiqo Key
struct ChameleonMessage {
    var timestamp = Date()
    // The status code of the operation, per Chameleon protocol
    var statusCode: ChameleonStatus?
    var command: ChameleonCommand?
    var data: Data?
}
