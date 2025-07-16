import Foundation

class ChameleonCodec {
    /// Array of all responses sent by Portiqo Key.
    private var continuation: CheckedContinuation<ChameleonMessage?, Never>?
    var response: ChameleonMessage? = nil {
        didSet {
            continuation?.resume(returning: response)
            continuation = nil
        }
    }

    var send: ((Data) -> Void)? // Closure for sending data out

    /// Receives incoming data from ConnectionManager, parses it, and adds it to the
    func handleIncomingData(_ data: Data) {
        print("Received message: \(data)")
        do {
            let message = try decodeMessage(data)
            self.response = message
        } catch {
            print("Error decoding message: \(error)")
        }
    }

    func sendAndWaitForResponse(_ message: ChameleonMessage) async throws -> ChameleonMessage {
        let messageToSend = try encodeMessage(message)
        send?(messageToSend)
        let response = await withCheckedContinuation { continuation in
            self.continuation = continuation
        }
        guard let response = response else {
            throw MessageError.noMessageReceived
        }
        return response
    }

    /// Encodes message for Portiqo key. All multi-bytes are in Big-Endian order.
    /// Frame format: https://github.com/RfidResearchGroup/ChameleonUltra/wiki/protocol#frame-format
    private func encodeMessage(_ message: ChameleonMessage) throws -> Data {
        guard let command = message.command else {
            // TODO: Error handling here
            print("No command provided")
            return Data()
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
        let lrc2 = calcLRC(frame[2...7])
        frame.append(lrc2)
        // The data, if any
        let data = message.data ?? Data()
        frame.append(data)
        // LRC for the data itself
        let lrc3 = calcLRC(data)
        frame.append(lrc3)
        // All done! That wasn't so bad!
        return frame
    }

    /// Checks data integrity and decodes a frame received from Portiqo Key
    /// Frame format: https://github.com/RfidResearchGroup/ChameleonUltra/wiki/protocol#frame-format
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
        let expectedLRC2 = calcLRC(frame[2...7]) // command through datablockLength
        let expectedLRC3 = calcLRC(data)
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


    /// Calculates the Longitudinal Redundancy Check for a given sequence of bytes using the formula
    func calcLRC(_ bytes: Data) -> UInt8 {
        let sum = bytes.reduce(0, { $0 &+ $1 }) // wrapping addition
        return (~sum &+ 1) & 0xFF
    }

}
