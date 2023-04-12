@testable import Alamofire
import XCTest

final class InternalRequestTests: BaseTestCase {
    func testThatMultipleFinishInvocationsDoNotCallSerializersMoreThanOnce() {
        // Given
        let session = Session(rootQueue: .main, startRequestsImmediately: false)
        let expect = expectation(description: "request complete")
        var response: DataResponse<Data?, AFError>?

        // When
        let request = session.request(.get).response { resp in
            response = resp
            expect.fulfill()
        }

        for _ in 0..<100 {
            request.finish()
        }

        waitForExpectations(timeout: timeout)

        // Then
        XCTAssertNotNil(response)
    }
}
