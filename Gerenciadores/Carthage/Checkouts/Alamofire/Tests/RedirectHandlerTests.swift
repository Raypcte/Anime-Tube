import Alamofire
import Foundation
import XCTest

final class RedirectHandlerTestCase: BaseTestCase {
    // MARK: - Properties

    private var redirectEndpoint: Endpoint { .get }
    private var endpoint: Endpoint { .redirectTo(redirectEndpoint) }

    // MARK: - Tests - Per Request

    func testThatRequestRedirectHandlerCanFollowRedirects() {
        // Given
        let session = Session()

        var response: DataResponse<Data?, AFError>?
        let expectation = self.expectation(description: "Request should redirect to /get")

        // When
        session.request(endpoint).redirect(using: Redirector.follow).response { resp in
            response = resp
            expectation.fulfill()
        }

        waitForExpectations(timeout: timeout)

        // Then
        XCTAssertNotNil(response?.request)
        XCTAssertNotNil(response?.response)
        XCTAssertNotNil(response?.data)
        XCTAssertNil(response?.error)

        XCTAssertEqual(response?.response?.url, redirectEndpoint.url)
        XCTAssertEqual(response?.response?.statusCode, 200)
    }

    func testThatRequestRedirectHandlerCanNotFollowRedirects() {
        // Given
        let session = Session()

        var response: DataResponse<Data?, AFError>?
        let expectation = self.expectation(description: "Request should NOT redirect to /get")

        // When
        session.request(endpoint).redirect(using: Redirector.doNotFollow).response { resp in
            response = resp
            expectation.fulfill()
        }

        waitForExpectations(timeout: timeout)

        // Then
        XCTAssertNotNil(response?.request)
        XCTAssertNotNil(response?.response)
        XCTAssertNil(response?.data)
        XCTAssertNil(response?.error)

        XCTAssertEqual(response?.response?.url, endpoint.url)
        XCTAssertEqual(response?.response?.statusCode, 302)
    }

    func testThatRequestRedirectHandlerCanModifyRedirects() {
        // Given
        let session = Session()
        let customRedirectEndpoint = Endpoint.method(.patch)

        var response: DataResponse<Data?, AFError>?
        let expectation = self.expectation(description: "Request should redirect to /patch")

        // When
        let redirector = Redirector(behavior: .modify { _, _, _ in customRedirectEndpoint.urlRequest })

        session.request(endpoint).redirect(using: redirector).response { resp in
            response = resp
            expectation.fulfill()
        }

        waitForExpectations(timeout: timeout)

        // Then
        XCTAssertNotNil(response?.request)
        XCTAssertNotNil(response?.response)
        XCTAssertNotNil(response?.data)
        XCTAssertNil(response?.error)

        XCTAssertEqual(response?.response?.url, customRedirectEndpoint.url)
        XCTAssertEqual(response?.response?.statusCode, 200)
    }

    // MARK: - Tests - Per Session

    func testThatSessionRedirectHandlerCanFollowRedirects() {
        // Given
        let session = Session(redirectHandler: Redirector.follow)

        var response: DataResponse<Data?, AFError>?
        let expectation = self.expectation(description: "Request should redirect to /get")

        // When
        session.request(endpoint).response { resp in
            response = resp
            expectation.fulfill()
        }

        waitForExpectations(timeout: timeout)

        // Then
        XCTAssertNotNil(response?.request)
        XCTAssertNotNil(response?.response)
        XCTAssertNotNil(response?.data)
        XCTAssertNil(response?.error)

        XCTAssertEqual(response?.response?.url, redirectEndpoint.url)
        XCTAssertEqual(response?.response?.statusCode, 200)
    }

    func testThatSessionRedirectHandlerCanNotFollowRedirects() {
        // Given
        let session = Session(redirectHandler: Redirector.doNotFollow)

        var response: DataResponse<Data?, AFError>?
        let expectation = self.expectation(description: "Request should NOT redirect to /get")

        // When
        session.request(endpoint).response { resp in
            response = resp
            expectation.fulfill()
        }

        waitForExpectations(timeout: timeout)

        // Then
        XCTAssertNotNil(response?.request)
        XCTAssertNotNil(response?.response)
        XCTAssertNil(response?.data)
        XCTAssertNil(response?.error)

        XCTAssertEqual(response?.response?.url, endpoint.url)
        XCTAssertEqual(response?.response?.statusCode, 302)
    }

    func testThatSessionRedirectHandlerCanModifyRedirects() {
        // Given
        let customRedirectEndpoint = Endpoint.method(.patch)

        let redirector = Redirector(behavior: .modify { _, _, _ in customRedirectEndpoint.urlRequest })
        let session = Session(redirectHandler: redirector)

        var response: DataResponse<Data?, AFError>?
        let expectation = self.expectation(description: "Request should redirect to /patch")

        // When
        session.request(endpoint).response { resp in
            response = resp
            expectation.fulfill()
        }

        waitForExpectations(timeout: timeout)

        // Then
        XCTAssertNotNil(response?.request)
        XCTAssertNotNil(response?.response)
        XCTAssertNotNil(response?.data)
        XCTAssertNil(response?.error)

        XCTAssertEqual(response?.response?.url, customRedirectEndpoint.url)
        XCTAssertEqual(response?.response?.statusCode, 200)
    }

    // MARK: - Tests - Per Request Prioritization

    func testThatRequestRedirectHandlerIsPrioritizedOverSessionRedirectHandler() {
        // Given
        let session = Session(redirectHandler: Redirector.doNotFollow)

        var response: DataResponse<Data?, AFError>?
        let expectation = self.expectation(description: "Request should redirect to /get")

        // When
        session.request(endpoint).redirect(using: Redirector.follow).response { resp in
            response = resp
            expectation.fulfill()
        }

        waitForExpectations(timeout: timeout)

        // Then
        XCTAssertNotNil(response?.request)
        XCTAssertNotNil(response?.response)
        XCTAssertNotNil(response?.data)
        XCTAssertNil(response?.error)

        XCTAssertEqual(response?.response?.url, redirectEndpoint.url)
        XCTAssertEqual(response?.response?.statusCode, 200)
    }
}

#if swift(>=5.5)
final class StaticRedirectHandlerTests: BaseTestCase {
    func takeRedirectHandler(_ handler: RedirectHandler) {
        _ = handler
    }

    func testThatFollowRedirectorCanBeCreatedStaticallyFromProtocol() {
        // Given, When, Then
        takeRedirectHandler(.follow)
    }

    func testThatDoNotFollowRedirectorCanBeCreatedStaticallyFromProtocol() {
        // Given, When, Then
        takeRedirectHandler(.doNotFollow)
    }

    func testThatModifyRedirectorCanBeCreatedStaticallyFromProtocol() {
        // Given, When, Then
        takeRedirectHandler(.modify { _, _, _ in nil })
    }
}
#endif
