import Alamofire
import Foundation
import XCTest

final class BasicAuthenticationTestCase: BaseTestCase {
    func testHTTPBasicAuthenticationFailsWithInvalidCredentials() {
        // Given
        let session = Session()
        let endpoint = Endpoint.basicAuth()
        let expectation = self.expectation(description: "\(endpoint.url) 401")

        var response: DataResponse<Data?, AFError>?

        // When
        session.request(endpoint)
            .authenticate(username: "invalid", password: "credentials")
            .response { resp in
                response = resp
                expectation.fulfill()
            }

        waitForExpectations(timeout: timeout)

        // Then
        XCTAssertNotNil(response?.request)
        XCTAssertNotNil(response?.response)
        XCTAssertEqual(response?.response?.statusCode, 401)
        XCTAssertNil(response?.data)
        XCTAssertNil(response?.error)
    }

    func testHTTPBasicAuthenticationWithValidCredentials() {
        // Given
        let session = Session()
        let user = "user1", password = "password"
        let endpoint = Endpoint.basicAuth(forUser: user, password: password)
        let expectation = self.expectation(description: "\(endpoint.url) 200")

        var response: DataResponse<Data?, AFError>?

        // When
        session.request(endpoint)
            .authenticate(username: user, password: password)
            .response { resp in
                response = resp
                expectation.fulfill()
            }

        waitForExpectations(timeout: timeout)

        // Then
        XCTAssertNotNil(response?.request)
        XCTAssertNotNil(response?.response)
        XCTAssertEqual(response?.response?.statusCode, 200)
        XCTAssertNotNil(response?.data)
        XCTAssertNil(response?.error)
    }

    func testHTTPBasicAuthenticationWithStoredCredentials() {
        // Given
        let session = Session()
        let user = "user2", password = "password"
        let endpoint = Endpoint.basicAuth(forUser: user, password: password)
        let expectation = self.expectation(description: "\(endpoint.url) 200")

        var response: DataResponse<Data?, AFError>?

        // When
        let credential = URLCredential(user: user, password: password, persistence: .forSession)
        URLCredentialStorage.shared.setDefaultCredential(credential,
                                                         for: .init(host: endpoint.host.rawValue,
                                                                    port: endpoint.port,
                                                                    protocol: endpoint.scheme.rawValue,
                                                                    realm: endpoint.host.rawValue,
                                                                    authenticationMethod: NSURLAuthenticationMethodHTTPBasic))
        session.request(endpoint)
            .response { resp in
                response = resp
                expectation.fulfill()
            }

        waitForExpectations(timeout: timeout)

        // Then
        XCTAssertNotNil(response?.request)
        XCTAssertNotNil(response?.response)
        XCTAssertEqual(response?.response?.statusCode, 200)
        XCTAssertNotNil(response?.data)
        XCTAssertNil(response?.error)
    }

    func testHiddenHTTPBasicAuthentication() {
        // Given
        let session = Session()
        let endpoint = Endpoint.hiddenBasicAuth()
        let expectation = self.expectation(description: "\(endpoint.url) 200")

        var response: DataResponse<Data?, AFError>?

        // When
        session.request(endpoint)
            .response { resp in
                response = resp
                expectation.fulfill()
            }

        waitForExpectations(timeout: timeout)

        // Then
        XCTAssertNotNil(response?.request)
        XCTAssertNotNil(response?.response)
        XCTAssertEqual(response?.response?.statusCode, 200)
        XCTAssertNotNil(response?.data)
        XCTAssertNil(response?.error)
    }
}

// MARK: -

final class HTTPDigestAuthenticationTestCase: BaseTestCase {
    func testHTTPDigestAuthenticationWithInvalidCredentials() {
        // Given
        let session = Session()
        let endpoint = Endpoint.digestAuth()
        let expectation = self.expectation(description: "\(endpoint.url) 401")

        var response: DataResponse<Data?, AFError>?

        // When
        session.request(endpoint)
            .authenticate(username: "invalid", password: "credentials")
            .response { resp in
                response = resp
                expectation.fulfill()
            }

        waitForExpectations(timeout: timeout)

        // Then
        XCTAssertNotNil(response?.request)
        XCTAssertNotNil(response?.response)
        XCTAssertEqual(response?.response?.statusCode, 401)
        XCTAssertNil(response?.data)
        XCTAssertNil(response?.error)
    }

    func testHTTPDigestAuthenticationWithValidCredentials() {
        // Given
        let session = Session()
        let user = "user", password = "password"
        let endpoint = Endpoint.digestAuth(forUser: user, password: password)
        let expectation = self.expectation(description: "\(endpoint.url) 200")

        var response: DataResponse<Data?, AFError>?

        // When
        session.request(endpoint)
            .authenticate(username: user, password: password)
            .response { resp in
                response = resp
                expectation.fulfill()
            }

        waitForExpectations(timeout: timeout)

        // Then
        XCTAssertNotNil(response?.request)
        XCTAssertNotNil(response?.response)
        XCTAssertEqual(response?.response?.statusCode, 200)
        XCTAssertNotNil(response?.data)
        XCTAssertNil(response?.error)
    }
}
