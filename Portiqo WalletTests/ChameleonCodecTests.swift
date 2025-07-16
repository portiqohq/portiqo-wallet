import Foundation
import Testing
@testable import Portiqo_Wallet

struct ChameleonCodecTests {
    @Test
    func calcLRC_singleByte() {
        let result = ChameleonCodec.calcLRC(Data([0x01]))
        #expect(result == 0xFF)
    }

    @Test
    func calcLRC_multipleBytes() {
        let result = ChameleonCodec.calcLRC(Data([0x01, 0x02, 0x03]))
        #expect(result == 0xFA)
    }

    @Test
    func calcLRC_empty() {
        let result = ChameleonCodec.calcLRC(Data())
        #expect(result == 0x00)
    }

}
