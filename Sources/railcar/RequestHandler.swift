import NIO
import NIOHTTP1

final class RequestHandler: ChannelInboundHandler {
    var group: MultiThreadedEventLoopGroup
    typealias InboundIn = HTTPServerRequestPart
    var requestHead: HTTPRequestHead?
    var requestData: RequestInfo?
    var requestBodyBuffer: ByteBuffer?

    init(group: MultiThreadedEventLoopGroup) {
        self.group = group
    }

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let req = unwrapInboundIn(data)

        switch req {
        case let .head(head):
            requestHead = head
            let headers = head.headers
            let url = head.uri
            let origin = context.remoteAddress?.description
            let method = head.method
            requestData = RequestInfo(url: url, headers: headers, method: method)
            requestBodyBuffer = context.channel.allocator.buffer(capacity: 0)
        case var .body(buffer: bodyBuffer):
            requestBodyBuffer?.writeBuffer(&bodyBuffer)
        case .end:
            if let bufferString = Utils.bufferToString(requestBodyBuffer) {
                requestData?.body = bufferString
            }

            var headers = HTTPHeaders()
            let channel = context.channel

            // Make Request
            if let requestData = self.requestData {
                fetch(requestInfo: requestData, group: group, eventLoop: context.eventLoop) { result in
                    switch result {
                    case let .failure(error):
                        errorCaught(context: context, error: error)
                    case let .success(response):
                        print(response)
                        let responseHead = HTTPResponseHead(
                            version: HTTPVersion(major: 1, minor: 1),
                            status: response.status,
                            headers: response.headers
                        )
                        let headpart = HTTPServerResponsePart.head(responseHead)

                        var buffer = channel.allocator.buffer(capacity: response.body?.capacity ?? 0)
                        let bodypart = HTTPServerResponsePart.body(.byteBuffer(response.body ?? buffer))
                        channel.write(headpart, promise: nil)
                        channel.write(bodypart, promise: nil)
                        channel.write(HTTPServerResponsePart.end(nil), promise: nil)
                        channel.flush()
                    }
                }
            }
        }

        func channelReadComplete(context: ChannelHandlerContext) {
            context.flush()
        }

        func errorCaught(context: ChannelHandlerContext, error: Error) {
            print("Railcar error: \(error.localizedDescription)")
            context.close(promise: nil)
        }
    }
}

struct RequestInfo {
    let url: String
    let headers: HTTPHeaders
    var body: String?
    let method: HTTPMethod

    init(url: String,
         headers: HTTPHeaders,
         body: String? = nil,
         method: HTTPMethod) {
        self.url = url
        self.headers = headers
        self.body = body
        self.method = method
    }
}
