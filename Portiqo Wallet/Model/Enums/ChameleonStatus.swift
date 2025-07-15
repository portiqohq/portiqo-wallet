enum ChameleonStatus: UInt16 {
    // High-frequency (HF) card statuses
    case hfTagOk = 0x00         // IC card operation is successful
    case hfTagNo = 0x01         // IC card not found
    case hfErrStat = 0x02       // Abnormal IC card communication
    case hfErrCRC = 0x03        // IC card communication verification abnormal
    case hfCollision = 0x04     // IC card conflict
    case hfErrBCC = 0x05        // IC card BCC error
    case mfErrAuth = 0x06       // MF card verification failed
    case hfErrParity = 0x07     // IC card parity error
    case hfErrATS = 0x08        // ATS should be present but card NAKed, or ATS too large

    // Low-frequency (LF) card statuses
    case lfTagOk = 0x40                 // Some operations with low frequency cards succeeded!
    case em410xTagNotFound = 0x41       // Unable to search for a valid EM410X label

    // Generic/system errors
    case parameterError = 0x60          // Invalid parameters from BLE command or function call
    case deviceModeError = 0x66         // Wrong device mode for requested operation
    case invalidCommand = 0x67
    case success = 0x68
    case notImplemented = 0x69
    case flashWriteFail = 0x70
    case flashReadFail = 0x71
    case invalidSlotType = 0x72
}
