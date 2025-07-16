import Foundation

class ChameleonCodec {
    /// Continuation used to fulfill a pending response request
    /// Note that only one continuation can be active at a time. If another request is made while `continuation` != nil,
    /// MessageError.pendingResponse will be thrown
    private var continuation: CheckedContinuation<ChameleonMessage, Error>?

    init(transmitClosure: @escaping (Data) -> Void) {
        self.transmitToDevice = transmitClosure
    }
    var transmitToDevice: ((Data) -> Void) // Closure for sending data out

    /// Handles raw data received from the Portiqo Key device.
    ///
    /// This method decodes the frame into a `ChameleonMessage` and resumes the awaiting continuation
    /// that was initiated via `sendAndWaitForResponse(_:)`.
    /// It must be called for every frame received from the device.
    ///
    /// - Parameter data: The raw byte sequence received from the device.
    /// - Note: If the data is malformed or validation fails, the pending continuation will be resumed with an error.
    /// - Important:
    func handleIncomingData(_ data: Data) {
        do {
            let message = try decodeMessage(data)
            continuation?.resume(returning: message)
        } catch {
            continuation?.resume(throwing: error)
        }
        continuation = nil
    }

    /// Sends a message to the Portiqo Key without waiting for a response.
    ///
    /// This is useful for commands that do not return data, such as simple triggers or state changes.
    ///
    /// - Parameter message: The message to encode and transmit.
    /// - Throws: `MessageError.noCommand` if the message lacks a command.
    func sendMessage(_ message: ChameleonMessage) async throws {
        let messageToSend = try encodeMessage(message)
        transmitToDevice(messageToSend)
    }

    /// Sends a message to the Portiqo Key device and awaits a response.
    ///
    /// This method encodes the given `ChameleonMessage`, transmits it using the `transmitToDevice` handler,
    /// and suspends until a response is received or an error occurs.
    func sendAndWaitForResponse(_ message: ChameleonMessage) async throws -> ChameleonMessage {
        guard continuation == nil else {
            throw MessageError.pendingResponse
        }
        try await sendMessage(message)
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
        }
    }

    /// Encodes a `ChameleonMessage` into data which can be accepted by Portiqo Key
    /// Frame format: https://github.com/RfidResearchGroup/ChameleonUltra/wiki/protocol#frame-format
    ///
    /// Parameter message: The message to encode.
    /// - Returns: A `Data` value containing the complete frame.
    /// - Throws: `MessageError.noCommand` if the provided message didn't provide a command.
    private func encodeMessage(_ message: ChameleonMessage) throws -> Data {
        guard let command = message.command else {
            throw MessageError.noCommand
        }
        var frame = Data()
        // Start of frame byte, always 0x11
        frame.append(0x11)
        // Longitudinal Redundancy Check of first byte. This will always be 0XEF since SOF never changes
        // So, we don't bother calculating it
        frame.append(0xEF)
        // Two-byte command code from documentation:
        // https://github.com/RfidResearchGroup/ChameleonUltra/wiki/protocol#data-payloads
        let commandCode = command.rawValue
        frame.append(UInt8(commandCode >> 8))
        frame.append(UInt8(commandCode & 0xFF))
        // Status code. This is always 0x0000 when sending messages TO the device
        frame.append(contentsOf: [0x00, 0x00])
        // Number of bytes contained in the data block. Maximum length is 512 bytes.
        // This is 0x00 if no message.
        let dataBlockLength = UInt16(message.data?.count ?? 0)
        frame.append(UInt8(dataBlockLength >> 8))
        frame.append(UInt8(dataBlockLength & 0xFF))
        // LRC for command, status, data length
        let lrc2 = Self.calcLRC(frame[2...7])
        frame.append(lrc2)
        // The data, if any
        let data = message.data ?? Data()
        frame.append(data)
        // LRC for the data itself
        let lrc3 = Self.calcLRC(data)
        frame.append(lrc3)
        // All done! That wasn't so bad!
        return frame
    }

    /// Creates a `ChameleonMessage` from the raw data provided by Portiqo Key, including integrity checks
    /// Frame format: https://github.com/RfidResearchGroup/ChameleonUltra/wiki/protocol#frame-format
    /// - Parameter frame: The raw byte sequence received from the device.
    /// - Returns: A `ChameleonMessage` with the data received from the Portiqo Key
    /// - Throws: `MessageError` if the frame is malformed, fails validation, or contains unknown command/status codes.
    func decodeMessage(_ frame: Data ) throws -> ChameleonMessage {
        let length = frame.count
        guard length >= 10 else {
            throw MessageError.frameTruncated
        }
        let sof = frame[0]
        guard sof == 0x11 else {
            throw MessageError.unexpectedFrameFormat
        }
        let lrc1 = frame[1]
        let commandCode = UInt16(frame[2]) << 8 | UInt16(frame[3])
        let statusCode = UInt16(frame[4]) << 8 | UInt16(frame[5])
        let datablockLength = Int(UInt16(frame[6]) << 8 | UInt16(frame[7]))
        let lrc2 = frame[8]
        guard length == 9 + datablockLength + 1 else {
            throw MessageError.frameTruncated
        }
        // Making sure to copy the data since we're going to deallocate the frame once we return
        let data = Data(frame[9..<length-1]) // 9-byte header prior to data
        let lrc3 = frame[length-1]
        // Make sure LRC checks pass OK
        let expectedLRC1: UInt8 = 0xEF
        let expectedLRC2 = Self.calcLRC(frame[2...7]) // command through datablockLength
        let expectedLRC3 = Self.calcLRC(data)
        guard lrc1 == expectedLRC1 && lrc2 == expectedLRC2 && lrc3 == expectedLRC3 else {
            throw MessageError.failedValidation
        }
        // Match command and status codes to their associated enums
        guard let command = ChameleonCommand(rawValue: commandCode) else {
            throw MessageError.unknownCommandReceived
        }
        guard let status = ChameleonStatus(rawValue: statusCode) else {
            throw MessageError.unknownStatusReceived
        }
        return ChameleonMessage(statusCode: status, command: command, data: data)
    }

    /// Calculates the Longitudinal Redundancy Check (LRC) for a sequence of bytes.
    ///
    /// The LRC is used for protocol-level validation of both message headers and payloads.
    /// It is computed as the two's complement of the sum of all bytes, modulo 256.
    ///
    /// - Parameter bytes: The byte sequence to compute the LRC for.
    /// - Returns: A single-byte checksum value.
    static func calcLRC(_ bytes: Data) -> UInt8 {
        let sum = bytes.reduce(0, { $0 &+ $1 }) // wrapping addition
        return (~sum &+ 1) & 0xFF
    }
}
