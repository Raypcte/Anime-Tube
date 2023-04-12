import Alamofire

extension DataRequest {
    /// Adds a validator which executes a closure before calling `validate()`.
    ///
    /// - Parameter closure: Closure to perform before validation.
    /// - Returns:           The `DataRequest`.
    func validate(performing closure: @escaping () -> Void) -> Self {
        validate { _, _, _ in
            closure()

            return .success(())
        }
        .validate()
    }
}
