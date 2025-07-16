import Foundation

class Chameleon {
    var codec: ChameleonCodec

    init(codec: ChameleonCodec) {
        self.codec = codec
    }

    func getAppVersion() async throws {
        let message = ChameleonMessage(command: .GET_APP_VERSION)
        let response = try await codec.sendAndWaitForResponse(message)
        if let data = response.data {
            print("Raw version data: \(data as NSData)")
            let major = data[0]
            let minor = data[1]
            print("v\(major).\(minor)")
        }
    }
}
