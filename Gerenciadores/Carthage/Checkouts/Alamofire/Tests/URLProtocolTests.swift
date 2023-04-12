import Alamofire
import Foundation
import XCTest

class ProxyURLProtocol: URLProtocol {
    // MARK: Properties

    enum PropertyKeys {
        static let handledByForwarderURLProtocol = "HandledByProxyURLProtocol"
    }

    lazy var session: URLSession = {
        let configuration: URLSessionConfiguration = {
            let configuration = URLSessionConfiguration.ephemeral
            configuration.headers = HTTPHeaders.default

            return configuration
        }()

        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)

        return session
    }()

    weak var activeTask: URLSessionTask?

    // MARK: Class Request Methods

    override class func canInit(with request: URLRequest) -> Bool {
        if URLProtocol.property(forKey: PropertyKeys.handledByForwarderURLProtocol, in: request) != nil {
            return false
        }

        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        if let headers = request.allHTTPHeaderFields {
            do {
                return try URLEncoding.default.encode(request, with: headers)
            } catch {
                return request
            }
        }

        return request
    }

    override class func requestIsCacheEquivalent(_ a: URLRequest, to b: URLRequest) -> Bool {
        false
    }

    // MARK: Loading Methods

    override func startLoading() {
        // rdar://26849668 - URLProtocol had some API's that didn't make the value type conversion
        let urlRequest = (request.urlRequest! as NSURLRequest).mutableCopy() as! NSMutableURLRequest
        URLProtocol.setProperty(true, forKey: PropertyKeys.handledByForwarderURLProtocol, in: urlRequest)
        activeTask = session.dataTask(with: urlRequest as URLRequest)
        activeTask?.resume()
    }

    override func stopLoading() {
        activeTask?.cancel()
    }
}

// MARK: -

extension ProxyURLProtocol: URLSessionDataDelegate {
    // MARK: NSURLSessionDelegate

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        client?.urlProtocol(self, didLoad: data)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let response = task.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }

        client?.urlProtocolDidFinishLoading(self)
    }
}

// MARK: -

class URLProtocolTestCase: BaseTestCase {
    var manager: Session!

    // MARK: Setup and Teardown

    override func setUp() {
        super.setUp()

        manager = {
            let configuration: URLSessionConfiguration = {
                let configuration = URLSessionConfiguration.default
                configuration.protocolClasses = [ProxyURLProtocol.self]
                configuration.headers["Session-Configuration-Header"] = "foo"

                return configuration
            }()

            return Session(configuration: configuration)
        }()
    }

    // MARK: Tests

    func testThatURLProtocolReceivesRequestHeadersAndSessionConfigurationHeaders() {
        // Given
        let endpoint = Endpoint.responseHeaders.modifying(\.headers, to: ["Request-Header": "foobar"])

        let expectation = self.expectation(description: "GET request should succeed")

        var response: DataResponse<Data?, AFError>?

        // When
        manager.request(endpoint)
            .response { resp in
                response = resp
                expectation.fulfill()
            }

        waitForExpectations(timeout: timeout)

        // Then
        XCTAssertNotNil(response?.request)
        XCTAssertNotNil(response?.response)
        XCTAssertNotNil(response?.data)
        XCTAssertNil(response?.error)
        XCTAssertEqual(response?.response?.headers["Request-Header"], "foobar")
        XCTAssertEqual(response?.response?.headers["Session-Configuration-Header"], "foo")
    }
}
