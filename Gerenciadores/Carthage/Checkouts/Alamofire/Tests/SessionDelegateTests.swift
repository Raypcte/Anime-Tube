@testable import Alamofire
import Foundation
import XCTest

final class SessionDelegateTestCase: BaseTestCase {
    // MARK: - Tests - Redirects

    func testThatRequestWillPerformHTTPRedirectionByDefault() {
        // Given
        let session = Session(configuration: .ephemeral)
        let redirectURLString = Endpoint().url.absoluteString

        let expectation = self.expectation(description: "Request should redirect to \(redirectURLString)")

        var response: DataResponse<Data?, AFError>?

        // When
        session.request(.redirectTo(redirectURLString))
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

        XCTAssertEqual(response?.response?.url?.absoluteString, redirectURLString)
        XCTAssertEqual(response?.response?.statusCode, 200)
    }

    func testThatRequestWillPerformRedirectionMultipleTimesByDefault() {
        // Given
        let session = Session(configuration: .ephemeral)

        let expectation = self.expectation(description: "Request should redirect")

        var response: DataResponse<Data?, AFError>?

        // When
        session.request(.redirect(5))
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
        XCTAssertEqual(response?.response?.statusCode, 200)
    }

    func testThatRequestWillPerformRedirectionFor307Response() {
        // Given
        let session = Session(configuration: .ephemeral)
        let redirectURLString = Endpoint().url.absoluteString

        let expectation = self.expectation(description: "Request should redirect to \(redirectURLString)")

        var response: DataResponse<Data?, AFError>?

        // When
        session.request(.redirectTo(redirectURLString, code: 307))
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

        XCTAssertEqual(response?.response?.url?.absoluteString, redirectURLString)
        XCTAssertEqual(response?.response?.statusCode, 200)
    }

    // MARK: - Tests - Notification

    func testThatAppropriateNotificationsAreCalledWithRequestForDataRequest() {
        // Given
        let session = Session(startRequestsImmediately: false)
        var resumedRequest: Request?
        var resumedTaskRequest: Request?
        var completedTaskRequest: Request?
        var completedRequest: Request?
        var requestResponse: DataResponse<Data?, AFError>?
        let expect = expectation(description: "request should complete")

        // When
        let request = session.request(.default).response { response in
            requestResponse = response
            expect.fulfill()
        }
        expectation(forNotification: Request.didResumeNotification, object: nil) { notification in
            guard let receivedRequest = notification.request, receivedRequest == request else { return false }

            resumedRequest = notification.request
            return true
        }
        expectation(forNotification: Request.didResumeTaskNotification, object: nil) { notification in
            guard let receivedRequest = notification.request, receivedRequest == request else { return false }

            resumedTaskRequest = notification.request
            return true
        }
        expectation(forNotification: Request.didCompleteTaskNotification, object: nil) { notification in
            guard let receivedRequest = notification.request, receivedRequest == request else { return false }

            completedTaskRequest = notification.request
            return true
        }
        expectation(forNotification: Request.didFinishNotification, object: nil) { notification in
            guard let receivedRequest = notification.request, receivedRequest == request else { return false }

            completedRequest = notification.request
            return true
        }

        request.resume()

        waitForExpectations(timeout: timeout)

        // Then
        XCTAssertNotNil(resumedRequest)
        XCTAssertNotNil(resumedTaskRequest)
        XCTAssertNotNil(completedTaskRequest)
        XCTAssertNotNil(completedRequest)
        XCTAssertEqual(resumedRequest, completedRequest)
        XCTAssertEqual(resumedTaskRequest, completedTaskRequest)
        XCTAssertEqual(requestResponse?.response?.statusCode, 200)
    }

    func testThatDidCompleteNotificationIsCalledWithRequestForDownloadRequests() {
        // Given
        let session = Session(startRequestsImmediately: false)
        var resumedRequest: Request?
        var resumedTaskRequest: Request?
        var completedTaskRequest: Request?
        var completedRequest: Request?
        var requestResponse: DownloadResponse<URL?, AFError>?
        let expect = expectation(description: "request should complete")

        // When
        let request = session.download(.default).response { response in
            requestResponse = response
            expect.fulfill()
        }
        expectation(forNotification: Request.didResumeNotification, object: nil) { notification in
            guard let receivedRequest = notification.request, receivedRequest == request else { return false }

            resumedRequest = notification.request
            return true
        }
        expectation(forNotification: Request.didResumeTaskNotification, object: nil) { notification in
            guard let receivedRequest = notification.request, receivedRequest == request else { return false }

            resumedTaskRequest = notification.request
            return true
        }
        expectation(forNotification: Request.didCompleteTaskNotification, object: nil) { notification in
            guard let receivedRequest = notification.request, receivedRequest == request else { return false }

            completedTaskRequest = notification.request
            return true
        }
        expectation(forNotification: Request.didFinishNotification, object: nil) { notification in
            guard let receivedRequest = notification.request, receivedRequest == request else { return false }

            completedRequest = notification.request
            return true
        }

        request.resume()

        waitForExpectations(timeout: timeout)

        // Then
        XCTAssertNotNil(resumedRequest)
        XCTAssertNotNil(resumedTaskRequest)
        XCTAssertNotNil(completedTaskRequest)
        XCTAssertNotNil(completedRequest)
        XCTAssertEqual(resumedRequest, completedRequest)
        XCTAssertEqual(resumedTaskRequest, completedTaskRequest)
        XCTAssertEqual(requestResponse?.response?.statusCode, 200)
    }
}
