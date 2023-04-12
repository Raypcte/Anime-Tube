import XCTest

#if SWIFT_PACKAGE && LEAKS && os(macOS)
final class LeaksTests: XCTestCase {
    func testForLeaks() {
        
        atexit {
            @discardableResult
            func leaksTo(_ file: String) -> Process {
                let out = FileHandle(forWritingAtPath: file)!
                defer {
                    if #available(OSX 10.15, *) {
                        try! out.close()
                    } else {
                        // Fallback on earlier versions
                    }
                }
                let process = Process()
                process.launchPath = "/usr/bin/leaks"
                process.arguments = ["\(getpid())"]
                process.standardOutput = out
                process.standardError = out
                process.launch()
                process.waitUntilExit()
                return process
            }
            let process = leaksTo("/dev/null")
            guard process.terminationReason == .exit && [0, 1].contains(process.terminationStatus) else {
                print("Process terminated: \(process.terminationReason): \(process.terminationStatus)")
                exit(255)
            }
            if process.terminationStatus == 1 {
                print("================")
                print("Leaks Detected!!!")
                leaksTo("/dev/tty")
            }
            exit(process.terminationStatus)
        }
    }
}
#endif
