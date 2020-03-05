import AsyncHTTPClient
import Foundation
import NIO
import NIOHTTP1

func fetch(requestInfo: RequestInfo,
           group: MultiThreadedEventLoopGroup,
           eventLoop _: EventLoop,
           completion: @escaping (Result<HTTPClient.Response, Error>) -> Void) {
    let httpClient = HTTPClient(eventLoopGroupProvider: .shared(group))
    defer {
        try? httpClient.syncShutdown()
    }

    guard var request = try? HTTPClient.Request(url: requestInfo.url, method: requestInfo.method) else { return }
    request.headers = requestInfo.headers
    request.body = .string(requestInfo.body ?? "")
    httpClient.execute(request: request).whenComplete { result in
        completion(result)
    }
}
