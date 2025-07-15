import Foundation

enum MessageError: Error, LocalizedError, Equatable {
    case unexpectedFrameFormat // Frame doesn't start with expected 0x11 header
    case frameTruncated // Received an unexpectedly short frame
    case failedValidation // One of the LRCs didn't match
    case unknownCommandReceived // Received a command code not listed in ChameleonCommand enum
    case unknownStatusReceived // Received a status code not listed in ChameleonStatus enum
    case noCommand // No command provided

    case unknown

    var errorDescription: String? {
        switch self {
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
        case .noCommand:
            return "No command provided in this message."
        case .unknown:
            return "An unknown error occurred."
        }
    }
}
