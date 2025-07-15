import Foundation
enum ChameleonCommand: UInt16 {
    case GET_APP_VERSION = 1000
    case HF14A_SCAN = 2000
    case EM410X_SCAN = 3000
}
