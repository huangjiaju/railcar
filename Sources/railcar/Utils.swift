import Foundation
import NIO

struct Utils {
    static func bufferToString(_ buffer: ByteBuffer?) -> String? {
        guard let buf = buffer else { return nil }
        guard let bufferString = buf.getString(at: buf.readerIndex,
                                               length: buf.readableBytes) else {
            return nil
        }
        if bufferString.count > 0 {
            return bufferString
        }
        return nil
    }

    static func bufferToData(_ buffer: ByteBuffer?) -> Data? {
        guard let buf = buffer else { return nil }
        guard let bufferData = buf.getData(at: buf.readerIndex,
                                           length: buf.readableBytes) else {
            return nil
        }
        return bufferData
    }
}
