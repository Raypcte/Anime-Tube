import Foundation

extension Bundle {
    static var test: Bundle {
        let bundle: Bundle
        #if SWIFT_PACKAGE
        bundle = Bundle.module
        #else
        bundle = Bundle(for: BaseTestCase.self)
        #endif

        return bundle
    }
}
