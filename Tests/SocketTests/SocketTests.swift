import XCTest
import Dispatch
@testable import Socket

class SocketTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        
        let server = try? Server(port: 2553)
        
        let group = DispatchGroup()
        group.enter()
        group.wait()
        
        XCTAssert(true)
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
