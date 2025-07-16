import Foundation

enum MessageError: Error, LocalizedError, Equatable {
    case pendingResponse // We're waiting for the response from another command
    case unexpectedFrameFormat // Frame doesn't start with expected 0x11 header
    case frameTruncated // Received an unexpectedly short frame
    case failedValidation // One of the LRCs didn't match
    case unknownCommandReceived // Received a command code not listed in ChameleonCommand enum
    case unknownStatusReceived // Received a status code not listed in ChameleonStatus enum
    case noMessageReceived // No message received from the device
    case noCommand // No command provided
    case unknown

    var errorDescription: String? {
        switch self {
        case .pendingResponse:
            return "Another command is already in progress. Wait for the response before sending another one."
        case .unexpectedFrameFormat:
            return "Received data that wasn't in expected format."
        case .frameTruncated:
            return "Received a frame that was unexpectedly short."
        case .failedValidation:
            return "The message failed LRC validation. Corrupted?"
        case .unknownCommandReceived:
            return "Unknown command code in this message."
        case .unknownStatusReceived:
            return "Unknown status code in this message."
        case .noMessageReceived:
            return "No message received back from Portiqo Key."
        case .noCommand:
            return "No command provided in this message."
        case .unknown:
            return "An unknown error occurred."
        }
    }
}
